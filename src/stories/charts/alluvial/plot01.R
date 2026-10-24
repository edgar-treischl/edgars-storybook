library(ggplot2)
library(ggalluvial)
library(dplyr)

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

survival_cols <- c(
  "Yes" = "#009E73",
  "No" = "#E69F00"
)

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
    width = 0.28,
    alpha = 0.65,
    color = NA
  ) +
  geom_stratum(
    width = 0.28,
    fill = "white",
    color = "#404040",
    linewidth = 0.6
  ) +
  geom_text(
    stat = "stratum",
    aes(label = after_stat(stratum)),
    size = 3,
    fontface = "bold",
    color = "#303030"
  ) +
  scale_x_discrete(
    limits = c("Class", "Sex", "Survived"),
    labels = c("Class", "Sex", "Survival"),
    expand = c(0.12, 0.12)
  ) +
  scale_fill_manual(
    name = "Survival",
    values = survival_cols,
    labels = c(
      "Yes" = "Survived",
      "No" = "Not survived"
    )
  ) +
  labs(
    title = "Who survived the Titanic?",
    subtitle = "Passenger class, sex, and survival",
    x = NULL,
    y = "Number of passengers",
    caption = "Source: Titanic dataset"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_line(
      color = "#E5E5E5",
      linewidth = 0.4
    ),
    axis.text.x = element_text(
      size = 12,
      color = "#303030"
    ),
    axis.text.y = element_text(
      color = "#555555"
    ),
    axis.title.y = element_text(
      color = "#555555",
      margin = margin(r = 10)
    ),
    legend.position = "bottom",
    legend.title = element_text(
      face = "bold",
      color = "#303030"
    ),
    legend.text = element_text(
      color = "#444444"
    ),
    plot.title = element_text(
      size = 14,
      face = "bold",
      color = "#222222",
      margin = margin(b = 5)
    ),
    plot.subtitle = element_text(
      size = 12,
      color = "#666666",
      margin = margin(b = 15)
    ),
    plot.caption = element_text(
      size = 9,
      color = "#888888",
      hjust = 0
    ),
    plot.margin = margin(15, 25, 15, 15)
  )


ggsave(
  "plot01.svg",
  plot = p,
  width = 5.3333,
  height = 3.3333,
  units = "in",
  device = "svg"
)