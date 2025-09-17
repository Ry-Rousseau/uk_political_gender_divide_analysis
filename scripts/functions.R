# Function to recode attitude responses to 0 to 1 scale
recode_attitude_0_to_1 <- function(x) {
  case_when(
    x == "Strongly agree" ~ 1,
    x == "Agree" ~ 0.75,
    x == "Neither agree nor disagree" ~ 0.5,
    x == "Disagree" ~ 0.25,
    x == "Strongly disagree" ~ 0,
    TRUE ~ NA_real_
  )
}


