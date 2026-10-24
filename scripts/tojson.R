# Built-in Titanic data
titanic_df <- as.data.frame(Titanic)


# Export to JSON
jsonlite::write_json(
  penguins,
  path = "penguins.json",
  pretty = TRUE,
  auto_unbox = TRUE
)


penguins <- palmerpenguins::penguins
