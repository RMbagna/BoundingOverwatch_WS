# ################################################################# #
#### LOAD LIBRARY AND DEFINE CORE SETTINGS                       ####
# ################################################################# #

# Clear environment and suppress package startup messages
suppressPackageStartupMessages({
  rm(list = ls())
  graphics.off()
  gc()
})

# Load required packages with error handling
tryCatch({
  library(apollo)
  library(jsonlite)
  library(optparse)
  library(dplyr)
}, error = function(e) {
  stop(paste("Package loading failed:", e$message))
})

option_list <- list(
  make_option(c("-i", "--input"), type="character", help="Input CSV file path"),
  make_option(c("-o", "--output"), type="character", help="Output directory path")
)
opt_parser <- OptionParser(option_list=option_list)
args <- parse_args(opt_parser)
input_file  <- args$input
output_dir  <- args$output

# Modify data loading to use the arguments
input_file <- if(!is.null(args$input)) args$input else
  file.path("G:\\My Drive\\myResearch\\Research Experimentation\\Apollo\\apollo\\data\\Bounding_Overwatch_Data\\HumanData_Bounding_Overwatch.csv")
output_dir <- if(!is.null(args$output)) args$output else "Output_BoundingOverwatch"


# Initialize Apollo with error handling
tryCatch({
  apollo_initialise()
}, error = function(e) {
  stop(paste("Apollo initialization failed:", e$message))
})

### Set core controls, based on DFT_route_choice.R
apollo_control = list(
  modelName       = "DFT_Bounding_Overwatch",
  modelDescr      = "DFT model on Bounding Overwatch data",
  indivID         = "id",
  nCores          = 4,
  outputDirectory = "Output_BoundingOverwatch",
  panelData      =  FALSE
)

# ################################################################# #
#### LOAD DATA AND APPLY TRANSFORMATION (DIVIDE BY 2)   05/15/025 only worked for 1/4 ofthe data ####
# ################################################################# #

# database <- tryCatch({

#   # Load and clean data
#   data_clean <- read.csv(input_file, header = TRUE) %>%
#     `colnames<-`(tolower(colnames(.))) %>%
#     filter(choice %in% 1:3) %>%
#     mutate(choice = as.numeric(choice)) %>%
#     na.omit()

#   # Identify consequence columns (C11 to C34)
#   consequence_cols <- grep("^c(1[1-4]|2[1-4]|3[1-4])$", names(data_clean), value = TRUE)

#  # Divide each consequence value by 2, clamp to [0.01, 1]
#   # data_transformed <- data_clean %>%
#   #  mutate(across(all_of(consequence_cols), ~ pmax(0.01, pmin(1, . / 2))))

#   data_transformed <- data_clean %>%
#   mutate(across(all_of(consequence_cols), ~ pmax(0.01, pmin(1, .))))  # Clamp only, no divide


#   message("Dataset loaded and divided by 2 with clamping.")
#   data_transformed

# }, error = function(e) {
#   stop(paste("Data loading failed:", e$message))
# })

# ################################################################# #
#### LOAD DATA AND APPLY GLOBAL NORMALIZATION    05/19/2025         ####
# ################################################################# #

database <- tryCatch({

  # Load and clean data
  data_clean <- read.csv(input_file, header = TRUE) %>%
    `colnames<-`(tolower(colnames(.))) %>%
    filter(choice %in% 1:3) %>%
    mutate(choice = as.numeric(choice))

  # Identify consequence columns (C11 to C34)
  consequence_cols <- grep("^c(1[1-4]|2[1-4]|3[1-4])$", names(data_clean), value = TRUE)

  # Remove rows where all C-values are missing
  data_filtered <- data_clean %>%
    filter(rowSums(is.na(across(all_of(consequence_cols)))) < length(consequence_cols))

  # Compute global max value across all consequence columns
  global_max <- max(data_filtered[ , consequence_cols], na.rm = TRUE)
  if (!is.finite(global_max) || global_max <= 0) global_max <- 1  # fallback safeguard

  # Normalize all C-values globally, clamp to [0.01, 1]
  data_normalized <- data_filtered %>%
    mutate(across(all_of(consequence_cols), ~ pmax(0.01, pmin(1, . / global_max))))

  message("Dataset loaded, cleaned, and globally normalized.")
  data_normalized

}, error = function(e) {
  stop(paste("Data loading failed:", e$message))
})



# ################################################################# #
#### DEFINE MODEL PARAMETERS                                     ####
# ################################################################# #

apollo_beta = c(
  asc_1 = 0, asc_2 = 0, asc_3 = 0,
  b_attr1 = log(1.1),  # Changed from 0 (neutral starting point)
  b_attr2 = log(0.9),  # Changed from 0 to log(0.9)
  b_attr3 = log(1.2),  # Changed from 0 to log(1.2)
  b_attr4 = log(1.0),  # Changed from 0 to log(1.0)
  phi1 = 1,   # Changed from 1 to more moderate starting value
  phi2 = 0,     # Kept at 0
  error_sd = 0.5,  # Changed to more moderate value
  timesteps = 10  # Changed from 1 to larger starting value
)

# Relax the fixed parameters - only fix one ASC for identification
apollo_fixed = c("asc_3", "timesteps")  # Fixed parameters

# ################################################################# #
#### DEFINE MODEL AND LIKELIHOOD FUNCTION                        ####
# ################################################################# #

apollo_probabilities = function(apollo_beta, apollo_inputs, functionality = "estimate") {

  apollo_attach(apollo_beta, apollo_inputs)
  on.exit(apollo_detach(apollo_beta, apollo_inputs))

  P = list()

  # DFT Settings with bounded and clamped attributes
  dft_settings = list(
    alternatives = c(alt1 = 1, alt2 = 2, alt3 = 3),
    avail        = list(alt1 = 1, alt2 = 1, alt3 = 1),
    choiceVar    = choice,
    attrValues   = list(
      alt1 = list(
        attr1 = pmax(0.01, pmin(1, c11)),
        attr2 = pmax(0.01, pmin(1, c12)),
        attr3 = pmax(0.01, pmin(1, c13)),
        attr4 = pmax(0.01, pmin(1, c14))
      ),
      alt2 = list(
        attr1 = pmax(0.01, pmin(1, c21)),
        attr2 = pmax(0.01, pmin(1, c22)),
        attr3 = pmax(0.01, pmin(1, c23)),
        attr4 = pmax(0.01, pmin(1, c24))
      ),
      alt3 = list(
        attr1 = pmax(0.01, pmin(1, c31)),
        attr2 = pmax(0.01, pmin(1, c32)),
        attr3 = pmax(0.01, pmin(1, c33)),
        attr4 = pmax(0.01, pmin(1, c34))
      )
    ),
    altStart = list(alt1 = asc_1, alt2 = asc_2, alt3 = asc_3),
    attrWeights = list(
      attr1 = exp(b_attr1),  
      attr2 = exp(b_attr2),
      attr3 = exp(b_attr3),
      attr4 = exp(b_attr4)
    ),
    attrScalings = 1,
    procPars = list(
      error_sd = pmax(0.01, pmin(1, error_sd)),  # Add lower bound
      timesteps = pmax(1, pmin(5, timesteps)),  # Add reasonable bounds
      phi1 = phi1,
      phi2 = phi2
    ),
    panelData = TRUE,
    componentName = "BoundingOverwatchDFT"
  )
  # Compute probabilities
  P[["model"]] = apollo_dft(dft_settings, functionality)
  # Prepare and return
  P = apollo_prepareProb(P, apollo_inputs, functionality)

  return(P)
}


# ################################################################# #
#### MODEL ESTIMATION                                            ####
# ################################################################# #
tryCatch({
  apollo_inputs <- apollo_validateInputs() #apollo_control, apollo_beta, apollo_fixed) 
  model = apollo_estimate(
    apollo_beta, apollo_fixed, apollo_probabilities, 
    apollo_inputs,
    estimate_settings = list(
      estimationRoutine = "bfgs",
      maxIterations = 2000,
      printLevel = 3
    )
  )

# ################################################################# #
#### MODEL OUTPUTS                                               ####
# ################################################################# #

# ----------------------------------------------------------------- #
#---- FORMATTED OUTPUT (TO SCREEN)                               ----
# ----------------------------------------------------------------- #

apollo_modelOutput(model)

# ----------------------------------------------------------------- #
#---- FORMATTED OUTPUT (TO FILE, using model name)               ----
# ----------------------------------------------------------------- #

apollo_saveOutput(model)

# Save output in MATLAB-compatible format
output <- list(
    asc_1 = model$estimate["asc_1"],
    asc_2 = model$estimate["asc_2"],
    asc_3 = model$estimate["asc_3"],
    b_attr1 = model$estimate["b_attr1"],
    b_attr2 = model$estimate["b_attr2"],
    b_attr3 = model$estimate["b_attr3"],
    b_attr4 = model$estimate["b_attr4"],
    phi1 = model$estimate["phi1"],
    phi2 = model$estimate["phi2"],
    error_sd = model$estimate["error_sd"],
    timesteps = model$estimate["timesteps"]
)

output_path <- file.path(output_dir, "DFT_output.json")
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)
write_json(output, output_path, auto_unbox=TRUE)

}, error = function(e) {
  message("ESTIMATION FAILED WITH ERROR:")
  message(e$message)
  message("\nTRACEBACK:")
  message(paste(traceback(), collapse="\n"))
  quit(status=1)
})