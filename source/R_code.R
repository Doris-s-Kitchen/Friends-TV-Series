#load the datasets
friends <- read.csv("friends.csv", sep = ",", header = TRUE)
friends_info <- read.csv("friends_info.csv", sep = ",", header = TRUE)
friends_emotions <- read.csv("friends_emotions.csv", sep = ",", header = TRUE)
friends_test <- 1
friends_test <- 2

#load tidyverse library for better structure
library(tidyverse)
# Define the main characters
main_characters <- c("Monica Geller", "Joey Tribbiani", "Chandler Bing", 
                     "Phoebe Buffay", "Rachel Green", "Ross Geller")

# Calculate the distribution of lines spoken by each main character
line_distribution <- friends |>
  filter(speaker %in% main_characters) |>  # Filter for main characters
  group_by(speaker) |>                     # Group by character
  summarise(total_lines = n()) |>         # Count the number of lines for each character
  arrange(desc(total_lines))                 # Sort by total lines

# Output the line distribution
cat("Distribution of lines spoken by main characters:\n")
print(line_distribution)

# Create a bar plot for the distribution of lines
ggplot(line_distribution, aes(x = reorder(speaker, total_lines), y = total_lines)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  theme_minimal() +
  labs(
    title = "Distribution of Lines Spoken by Main Characters in Friends",
    x = "Characters",
    y = "Total Lines"
  ) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels for readability

# Filter for characters that are not main characters and meet the criteria
non_main_characters <- friends |>
  filter(!(speaker %in% main_characters) & 
           !is.na(speaker) & 
           speaker != "#ALL#" &
           speaker != "Scene Directions") |>
  group_by(speaker) |>
  summarise(total_lines = n(), 
            na.rm = TRUE) |>
  filter(total_lines > 150 ) |>
  arrange(desc(total_lines))


# Create a bar plot for the distribution of lines
ggplot(non_main_characters, aes(x = reorder(speaker, total_lines), y = total_lines)) +
  geom_bar(stat = "identity", fill = "lightcoral") +
  theme_minimal() +
  labs(
    title = "Non-Main Characters with More lines in Friends",
    x = "Characters",
    y = "Total Lines"
  ) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels for readability

# Filter the dataset for the three speakers
speaker_distribution <- friends |>
  filter(speaker %in% c("Janice Litman Goralnik", "Mike Hannigan", "Richard Burke")) |>
  group_by(speaker, season) |>
  summarise(Number_of_Lines = n(), .groups = "drop")

# Create bins to ensure seasons 1 to 10 are represented
speaker_distribution <- speaker_distribution |>
  complete(season = 1:10, speaker, fill = list(Number_of_Lines = 0))

# Plot the distribution of lines for the three speakers
ggplot(speaker_distribution, aes(x = factor(season), y = Number_of_Lines, fill = speaker)) +
  geom_bar(stat = "identity", position = "dodge", color = "black") +
  theme_minimal() +
  labs(
    title = "Line Distribution for Selected Characters Across Seasons",
    x = "Season",
    y = "Number of Lines",
    fill = "Speaker"
  ) +
  scale_fill_manual(values = c("skyblue", "orange", "lightgreen")) +  # Custom colors for speakers
  theme(
    plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
    axis.title = element_text(size = 12),
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 10)
  )

# Calculate the distribution of lines spoken by each character (main and non-main), excluding "Scene Directions"
line_distribution <- friends |>
  filter(speaker != "Scene Directions") |>  # Exclude "Scene Directions"
  group_by(season, episode, speaker) |>   # Group by season, episode, and speaker
  summarise(total_lines = n(), .groups = 'drop')  # Count the number of lines for each speaker

# Find the speaker with the most lines in each episode of each season
most_lines_per_episode <- line_distribution |>
  group_by(season, episode) |>
  filter(total_lines == max(total_lines))

# Filter for episodes where the speaker with the most lines is a non-main character
non_main_results <- most_lines_per_episode |>
  filter(!(speaker %in% main_characters))

# Output the result
if (nrow(non_main_results) > 0) {
  print("Episodes where a non-main character has the most lines:")
  print(non_main_results)
} else {
  print("No episodes where a non-main character has the most lines.")
}

# Filter for lines where the speaker is Joey
joey_lines <- subset(friends, speaker == "Joey Tribbiani")

# Count the occurrences of "How you doin?" in the 'text' column (case insensitive)
how_you_doin_count <- sum(grepl("How you doin?", joey_lines$text, ignore.case = TRUE))

# Print the result
cat("Joey says 'How you doin?'", how_you_doin_count, "times.\n")

# Count occurrences of "How you doin?" in each season
how_you_doin_by_season <- aggregate(
  grepl("How you doin?", joey_lines$text, ignore.case = TRUE) ~ joey_lines$season,
  data = joey_lines,
  FUN = sum
)

# Rename columns for clarity
colnames(how_you_doin_by_season) <- c("season", "count")

# Load ggplot2 library for plotting
library(ggplot2)

# Create a line plot with customized x-axis
ggplot(how_you_doin_by_season, aes(x = season, y = count)) +
  geom_line(color = "blue", size = 1) +        # Line with color and thickness
  geom_point(color = "red", size = 3) +        # Points at each data value
  labs(
    title = "Number of Times Joey Says 'How you doin?' by Season",
    x = "Season",
    y = "Count"
  ) +
  scale_x_continuous(breaks = 0:10, limits = c(0, 10)) +  # X-axis from 0 to 10
  theme_minimal()

# Count occurrences of "I love you" for each main character
love_you_count <- friends |>
  filter(speaker %in% main_characters & str_detect(text, "I love you")) |>  # Filter main characters and text
  group_by(speaker) |>                        # Group by speaker
  summarise(total_count = n()) |>            # Count occurrences
  arrange(desc(total_count))                   # Sort by total count in descending order

# Output the total counts for each character
cat("Occurrences of 'I love you' by each main character:\n")
print(love_you_count)

# Identify the character who said "I love you" the most
most_love = love_you_count |>
  filter(total_count == max(total_count))

cat("The character who said 'I love you' the most is:", most_love$speaker, "with", most_love$total_count, "occurrences.\n")

# Count occurrences of "I love you" for the main characters by season
love_you_by_season <- friends |>
  filter(speaker %in% main_characters & str_detect(text, "I love you")) |>
  group_by(season, speaker) |>
  summarise(total_count = n(), .groups = "drop") |>
  arrange(season)


# Create a plot for the counts
ggplot(love_you_by_season, aes(x = season, y = total_count, color = speaker)) +
  geom_line(size = 1) +                                  # Add lines for each character
  geom_point(size = 3) +                                 # Add points to the lines
  theme_minimal() +
  labs(
    title = "Occurrences of 'I love you' by six main charactors Through the Seasons",
    x = "Season",
    y = "Total Occurrences"
  ) +
  scale_x_continuous(breaks = 1:10, limits = c(1, 10)) +  # Set x-axis from 1 to 10 (seasons)
  scale_y_continuous(breaks = seq(0, max(love_you_by_season$total_count), by = 1)) +  # Set y-axis as integers
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels for readability
#Fit linear models with imdb_rating as the predictor and us_views_millions as the response, and 
#vice versa. Plot both and compare to choose the response variable.
fit <- lm(imdb_rating ~ us_views_millions, data = friends_info)
plot(friends_info$us_views_millions, friends_info$imdb_rating)
fit.1 <- lm(us_views_millions ~ imdb_rating, data = friends_info)
plot(friends_info$imdb_rating, friends_info$us_views_millions)

# remove outliers (unnecessary)
#friends_info <- friends_info |>
#  filter(!(row_number() %in% c(36,37,235, 236)))
#See the QQ-plots and residual plots of the model:
plot(fit)
summary(fit)

#try transformations for y:
library(MASS)
boxcox(fit)

#fit models with different transformations:
fit.reciprocal <- lm(1 /imdb_rating ~ us_views_millions, data = friends_info)
fit.log <- lm(log(imdb_rating) ~ us_views_millions, data = friends_info)
fit.sqrt <- lm(sqrt(imdb_rating) ~ us_views_millions, data = friends_info)

#Compare the plots of different transformations of y:
plot(fit.reciprocal)
plot(fit.log)
plot(fit.sqrt)

#Non transform is the best: easy interpretation.

