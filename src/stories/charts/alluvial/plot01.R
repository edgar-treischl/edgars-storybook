library(ggplot2)
library(ggalluvial)
library(dplyr)

# 1. Prepare Titanic data
dat <- as.data.frame(Titanic) |>
  group_by(Class, Sex, Survived) |>
  summarise(
    n = sum(Freq),
    .groups = "drop"
  ) |>
  mutate(
    Class = factor(Class, levels = c("1st", "2nd", "3rd", "Crew")),
    Sex = factor(Sex, levels = c("Female", "Male")),
    Survived = factor(Survived, levels = c("Yes", "No"))
  )

# 2. Define colors
survival_cols <- c(
  "Yes" = "#009E73",
  "No" = "#E69F00"
)

# 3. Alluvial chart
p <- ggplot(
  dat,
  aes(
    axis1 = Class,
    axis2 = Sex,
    axis3 = Survived,
    y = n
  )
) +
  geom_alluvium(
    aes(fill = Survived),
    width = 0.25,
    alpha = 0.7,
    color = NA
  ) +
  geom_stratum(
    width = 0.25,
    fill = "white",
    color = "#404040",
    linewidth = 0.35
  ) +
  geom_text(
    stat = "stratum",
    aes(label = after_stat(stratum)),
    size = 7 / ggplot2::.pt,
    fontface = "bold",
    color = "#303030"
  ) +
  scale_x_discrete(
    limits = c("Class", "Sex", "Survived"),
    labels = c("Class", "Sex", "Survival"),
    expand = expansion(add = 0.12)
  ) +
  scale_fill_manual(
    name = "Survival",
    values = survival_cols,
    labels = c(
      "Yes" = "Survived",
      "No" = "Not survived"
    )
  ) +
  scale_y_continuous(
    expand = expansion(mult = c(0.02, 0.06))
  ) +
  labs(
    title = "Who survived the Titanic?",
    subtitle = "Passenger class, sex, and survival",
    x = NULL,
    y = "Number of passengers",
    caption = "Source: Titanic dataset"
  ) +
  theme_minimal(base_size = 9) +
  theme(
    plot.title = element_text(
      size = 12,
      face = "bold",
      color = "#25364A",
      margin = margin(b = 4)
    ),
    plot.subtitle = element_text(
      size = 8,
      color = "grey40",
      margin = margin(b = 8)
    ),
    plot.caption = element_text(
      size = 6,
      color = "grey55",
      hjust = 0,
      margin = margin(t = 8)
    ),
    axis.text.x = element_text(
      size = 7.5,
      face = "bold",
      color = "#25364A"
    ),
    axis.text.y = element_text(
      size = 7,
      color = "grey50"
    ),
    axis.title.y = element_text(
      size = 8,
      face = "bold",
      color = "grey30",
      margin = margin(r = 8)
    ),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(
      linewidth = 0.26,
      color = "#E8EBEF"
    ),
    legend.position = "bottom",
    legend.title = element_text(
      size = 8,
      face = "bold",
      color = "#25364A"
    ),
    legend.text = element_text(
      size = 7,
      color = "grey40"
    ),
    legend.key.height = grid::unit(8, "pt"),
    legend.key.width = grid::unit(12, "pt"),
    legend.spacing.x = grid::unit(4, "pt"),
    plot.margin = margin(8, 12, 8, 8)
  )

p

# Alluvial
ggsave(
  "src/stories/charts/alluvial/plot01-r.svg",
  plot = p,
  width = 5.3333,
  height = 3.3333,
  units = "in",
  device = svglite::svglite,
  bg = "white"
)
