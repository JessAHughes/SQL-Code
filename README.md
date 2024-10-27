	--Nashville Housing dataset--
	-I cleaned the data up by deleting unused columns or duplicates, unifying selling information, seperating addresses into multiple columns (Street, City, State), and reformatting the dates to be easier to use. I had to go down a stack overflow rabbit hole to get the duplicate columns to all delete at once, but it was worth it to run that codeblock. 
	-Changing the date, which was currently a string, to a DATE type was a bit of a headache, since I first had to change the string to DATETIME, and THEN change that to DATE since the INSERT INTO arguement didn't error out when just using STR_TO_DATE, but also didn't do what I wanted it to, but it was such a relief when I finally got it to work!
	--Automobile Data Cleaning--
	-Here I took the dataset at https://archive.ics.uci.edu/ml/datasets/Automobile from the 1985 Ward's Automotive Yearbook to do some cleaning. It was fairly straightforward data cleaning, and I used the data description at the link to check if there were any values outside the range of the correct values.
	--Coffee Sales--
 	-This is using a couple small data sets relating to sales data of coffee related items in the middle east. Used to help narrow down options to what would be the best cities to open up a new coffee supplier.
  
