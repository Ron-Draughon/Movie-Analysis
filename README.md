**Data Analysis Report: Maximizing ROI in Movie Production** *Prepared for Fledgling Movie Studio*

**Problem Statement:** Fledgling Movie Studio is standing on the precipice of a significant financial opportunity. Armed with $100 million in venture capital, the studio aims to produce a movie (or group of movies) with the highest Return on Investment (ROI). By generating the highest possible ROI for their upcoming movie(s), the studio aims to secure future investments, attract potential partners, and position itself as a formidable player in the highly competitive film industry.

**Executive Summary:** In my analysis aimed at helping Fledgling Movie Studio maximize ROI for its upcoming movie (or movies), several key insights have been identified based on various influential factors such as genre, release date, budget, runtime, writers, and directors.

**Data Sources:** The dataset used for this analysis was sourced from Kaggle, available at [this link](https://www.kaggle.com/datasets/danielgrijalvas/movies). It comprises over 7,000 movies scraped from IMDb.

**Data Limitations:** It's important to acknowledge the limitations of the dataset used for analysis:

- The "genre" category was derived from selecting the first of two or three genres listed on the movie's IMDb page, leading to some misrepresentations in movie categorization.
- The sample size for some genres was skewed due to the methodology used in the data scraping. For instance, according to the dataset, the family genre only had 3 movies released since 1990, which is clearly inaccurate.
- To ensure a more accurate analysis, two movies with exceptionally high ROIs ("Paranormal Activity" 1,288,939% and "The Blair Witch Project" 414,299) were excluded due to their disproportionate influence on the results.

**Analysis Steps:**

1. **Data Extraction:** Retrieve relevant movie data from the dataset sourced from Kaggle.
1. **Data Cleaning and Formatting:** Cleanse and format the data in Excel, including handling missing values, duplicates, and inconsistencies.
1. **Data Transfer to SQL:** Transfer the cleaned and formatted data from Excel to SQL for further analysis.
1. **Data Transformation:** Perform necessary transformations such as calculating ROI, joining tables to gather relevant information, and grouping movies by genre, release month, rating, budget, runtime, writer, and director.

Here are the findings of my analysis based on movies released since 1990.

1. **Horror Genre Dominates in ROI:**

   
![Movies ROI by Genre](https://github.com/Ron-Draguhon/Movie-Analysis/assets/56360122/d95dffc4-2229-441d-9aa8-46957b6cddc2)


- Horror movies significantly outperform movies from every other genre in terms of average ROI by almost 2-to-1, and almost 4 times the industry average of 274%.
- Horror movies also have less competition in the genre than movies in other genres.

1. **Genre and Release Month:**

![Movie ROI by Genre   Month](https://github.com/Ron-Draguhon/Movie-Analysis/assets/56360122/4edc5c27-dc59-4a8c-b89c-2860f97540cd)

- Horror movies tend to yield the highest average ROIs in specific months, with April, October, and January standing out as particularly lucrative release periods.
- Seasonal trends indicate that movies in the horror genre perform exceptionally well in the lead-up to Halloween (October) and during the spring months (April).
1. **ROI by Genre and Rating:**

![Movie ROI by Genre   Rating](https://github.com/Ron-Draguhon/Movie-Analysis/assets/56360122/b1a3f236-1500-4dac-b4dc-7bdee4b88654)


- Horror movies exhibit considerably higher average ROIs compared to other genres, regardless of rating. PG-13 and R-rated horror movies, in particular, show the most robust performances, with PG-13 movies performing slightly better in terms of average ROI.

1. **Runtime Considerations:**

![Horror Movie ROI by Runtime](https://github.com/Ron-Draguhon/Movie-Analysis/assets/56360122/2a9cda68-354c-4b8a-ba62-688ee3d28dd9)

- Shorter runtimes (under 90 minutes) are associated with the highest average ROIs in horror movies, emphasizing the value of concise storytelling.
- Longer runtimes show diminishing returns, suggesting potential challenges in maintaining audience engagement for extended periods.

1. **Budget Impact on ROI:**

![Horror Movie ROI by Budget](https://github.com/Ron-Draguhon/Movie-Analysis/assets/56360122/3bd1ae7a-2369-49de-9b42-c4fcecd9698f)

- Horror movies with budgets under $10 million have significantly higher ROI than those with larger budgets.  
- Budgets between $10-50 million show a significant drop in ROI for horror movies but are still at or around the industry average of 274%.
- Horror movies with a budget of over $50 million have an astronomical drop-off in ROI (only 0.54%).


1. **Writer and Director Impact on ROI:**

![Movie Directors ROI](https://github.com/Ron-Draguhon/Movie-Analysis/assets/56360122/c49cef5a-05ec-461d-bbb6-d57d85df835f)

![Movie Writers ROI](https://github.com/Ron-Draguhon/Movie-Analysis/assets/56360122/9c391332-a10c-48da-9ea4-24ae00592b44)


- Writer Leigh Whannell and director James Wan demonstrate consistently higher average ROIs than others in their field, averaging over 3000% ROI per film. Collaboration between these experienced individuals may enhance Fledgling Movie Studio's chances of achieving financial success.

**Recommendations:**

- **Produce Horror Movies:** In terms of ROI, horror movies dominate films from every other genre with almost 4 times the industry average of 274%.
- **Focus on Lower Budget Horror Movies:** Given the strong correlation between lower budgets and higher ROIs, Fledgling Movie Studio should produce horror movies with budgets under $10 million and avoid making horror movies with a budget of over $50 million.
- **Strategic Release Planning:** Align movie release dates within peak months for the horror genre (April, October, and January) to capitalize on audience interest.
- **Optimal Runtimes:** Aim for shorter runtimes, particularly under 90 minutes, to maximize audience engagement and ROI.
- **Select Experienced Writers and Directors:** Collaborate with writers and directors who have a proven track record of delivering high ROIs in the horror genre, such as writer Leigh Whannell and director James Wan.

**Conclusion:** By incorporating these recommendations, Fledgling Movie Studio can strategically position itself to produce movies with the highest possible ROI. Leveraging insights from the analysis, if the movies the studio produces bring in the industry average for the horror genre, the initial investment of $100 million should bring in over $1 billion in profit.
