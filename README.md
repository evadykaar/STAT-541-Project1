**Overview of Our Dataset**
- https://data.seattle.gov/Public-Safety/Seattle-Real-Time-Fire-911-Calls/kzjm-xkqj/about_data
- Our dataset is of 911 Calls from Seattle Washington
- This dataset was created January 8th, 2010, and is still being updated (every 5 minutes), however, our data is not continuously updating since it was initially downloaded.
- 1.92 million rows, 7 columns
- The variables in this data include location of incident, response type, date/time of call, latitude, longitude, report location, and incident number.

**Data Cleaning**
- The original file was about almost 2 million rows long, so we wanted to condense the dataset.
- We took a random sample of the original dataset to condense it to 500,000 rows.
- We then subsetted it to include only 2023 accidents.
- We also only included the top accident types to keep the app condensed and readable.
- We had to convert the datetime variable into datetime format.
- Then, we extracted year and month variables.

**Scripts and Files in Our Folder**
- In our folder, we have one file that is an R script that contains our app called Project_1.R.
- We also have a data folder that contains our small dataset named Seattle_small_911.csv

**Capabilities of the App**
- In our app, you can filter by accident type and month.
- Our map, time series plot, and average number of accidents value box all affected by these filters.
- Each data point on the map represents a 911 call and when you click on a point the resulting incident number, address, accident type, and date/time pops up.
