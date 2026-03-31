# Straight from https://www.fbi.gov/file-repository/cjis/nics-participation-map-020124/view

nics_participation <- data.frame(
  state = c(
    # Non-POC
    "Alabama", "Alaska", "Arizona", "Arkansas", "Delaware",
    "District of Columbia", "Georgia", "Idaho", "Indiana", "Iowa",
    "Kansas", "Kentucky", "Louisiana", "Maine", "Massachusetts",
    "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana",
    "New Mexico", "North Carolina", "North Dakota", "Ohio", "Oklahoma",
    "Rhode Island", "South Carolina", "South Dakota", "Texas", "Vermont",
    "West Virginia", "Wyoming",
    "American Samoa", "Guam", "N. Mariana Islands", "Puerto Rico", "Virgin Islands",
    # Full POC
    "California", "Colorado", "Connecticut", "Florida", "Hawaii",
    "Illinois", "Nevada", "New Jersey", "New York", "Oregon",
    "Pennsylvania", "Tennessee", "Utah", "Virginia", "Washington",
    # Partial POC Handgun
    "Maryland", "New Hampshire", "Wisconsin",
    # Partial POC Permit
    "Nebraska"
  ),
  participation = factor(
    c(
      rep("Non-POC", 37),
      rep("Full POC", 15),
      rep("Partial POC - Handgun", 3),
      rep("Partial POC - Permit", 1)
    ),
    levels = c("Non-POC", "Partial POC - Handgun", "Partial POC - Permit", "Full POC"),
    ordered = TRUE
  )
)

# Can used the data later without all this hassle.
saveRDS(nics_participation, file = "data/other_sources/nics_participation.RDS")