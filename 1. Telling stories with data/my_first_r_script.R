#Reminder to self: to get only certain sections of the code to run,
#highlight that section, and click the "run" icon in the top RHS
#of the source code pane.

#Install packages
install.packages("tidyverse")
install.packages("AustralianPoliticians")

#load packages we need for this time
library(tidyverse)
library(AustralianPoliticians)

#make table of counts of genders of the PMs
get_auspol("all") |> #this imports data from GitHub
  as_tibble() |>
  filter(wasPrimeMinister == 1) |>
  count(gender)
#this gave us an output tibble that says female = 1, male = 29
#grammar note: the |> is called a pipe; it tells R to read the instructions
#as "this and then." I.e. it takes the output of my first line
#of code to feed into the next line of code. Another way to write the pipe
#could be %>%. The pipe is super useful for multi-step operations
#to my data.

#get the first six headings from the aus_pol dataset by using the
#"head" function

get_auspol("all") |> #pipe the data into just 6 columns, thanks.
  head()
#that gave us a tibble of 6 columns; plus the console tells us there are 14 more 
#columns that it cut out to make this head() for us. 

#workflow note: for this script, I used data pulled from GitHub. If I want to 
#use data that I store locally on my computer, I should "upload" the 
#file to the "files" panel on the bottom RHS. Then I can use relational
#file paths inside the working directory (the folder I told R to do everything
#related to this project.)

#I also set the folder on my computer "INF Data Science" as the working directory,
#by clicking "More" in the "files" panel, and clicked "set working directory."

australian_politicians <- get_auspol("all") 
head(australian_politicians)

#use "select" to only look at a specific column in the dataset, like "firstname"
#or just "commonName".

australian_politicians |>
  select(firstName)
#this printer out just the column of first names

australian_politicians |>
  select(commonName)
#I can also select two columns to put together simply by adding a comma
australian_politicians |>
  select(firstName, commonName) #that outputted a two column table 

#We can also use "select" to remove columns by using a negative sign

australian_politicians |>
  select(-firstName)

#I can also use "select" to pick columns based on conditions. For example
#if I only care about columns that start with "birth":

australian_politicians |>
  select(starts_with("birth"))
#that outputted a table of just three columns, which were the three
#with "birth" in the beginning of the title. birthDate, birthYear, birthPlace.

#I can also select based on ends_with
australian_politicians |>
  select(ends_with("Place"))
#that gave me a one column with birthPlace

#I can also select based on contains()

australian_politicians |>
  select(contains("name"))
#that gave me a table of six columns with the word 'name' in it, both
#capital and lower case

#I can also use select to display only certain columns, not all

australian_politicians |>
  select(uniqueID, surname, firstName, gender, birthDate, birthYear, deathDate, member, senator, wasPrimeMinister)
australian_politicians
#that printed out the selected columns I wanted, no more.

australian_politicians |>
  filter(wasPrimeMinister == 1) #that filters out specific rows in a tibble
#that show us this person was a prime minister (1 is yes, 0 is no)

#I can combine with with an AND operator to make it more specific
#e.g. I only care about politicians that were PM and named Joseph

australian_politicians |> 
  filter(wasPrimeMinister == 1 & firstName == "Joseph")
#that gives me a table of all people whose has firstName of Joseph
#and they were PM
#alternatively use a comma to do AND instead of the &
#I can also do an OR operation using the |

australian_politicians |>
  filter(firstName == "Myles"| firstName == "Ruth")
#that outputted a table of people whose first names were either
#Myles or Ruth

#I could also pipe this result into select. that is, i filter for Myles
#and Ruth and then say I only wanna look at the columns called firstName
#and surname


australian_politicians |>
  filter(firstName == "Myles"| firstName == "Ruth") |>
  select(firstName, surname)
#that gave a two column table with only the sections firstname and surname for
#those people named Ruth or Myles

#if I needed to just look at a specific row I can use filter() for that too

australian_politicians |> 
  filter(row_number() == 865)
#that gave us the guy named Donald Jessop.

#If I needed to remove a specific row or sets of rows, I can use slice()
australian_politicians |>
  slice(-1) #removes the first row using that negative sign

#plus slice() lets us KEEP specific rows if we don't use the negative sign
australian_politicians |>
  slice(1:3)

#i could use arrange() to change the order of the dataset depending
#on the values of certain columns
#e.g. i want to arrange the politicians by their birthday

australian_politicians |>
  arrange(birthYear)
#that gave us a table starting with Richard Edwards who has the earliest birthday,
#in 1842

#if i wanted descending birthdates intead of increasing, use 
australian_politicians |>
  arrange(desc(birthYear))
#or I could just use the minus sign to mean descending
australian_politicians |>
  arrange(-birthYear)

#if i want two conditions i could do it by arrange too
#for example arrange by politicians' firstName then by their birthYear

australian_politicians |>
  arrange(firstName, birthYear)

#this is another way to do the same thing/think about the same thing
australian_politicians |>
  arrange(birthYear) |>
  arrange(firstName)

#use mutate() to create new column
#e.g. let's make a new column that says 1 if that person is both
#senator and member. otherwise it says 0.

australian_politicians <- 
  australian_politicians |> 
  mutate(was_both = if_else(member == 1 & senator == 1, 1, 0))

australian_politicians |>
  select(member, senator, was_both)

#can do lots of math like calculate their ages in 2024
#and put that age in a new column at the end of the table called "age"

library(lubridate)
australian_politicians <- australian_politicians |>
 mutate(age = 2024 - year(birthDate))

#there's options to do log(), lead() which brings columns up by one row, lag()
#which pushes columns down by one dow, and cumsum() which makes a cumulative
#sum of the column

#plus I can use case_when() to make a new column BASED ON TWO CONDITIONAL STATEMENTS
#like 'hey i have years and i want them grouped into decades'
australian_politicians |>
  mutate(
    year_of_birth = year(birthDate),
    decade_of_birth = 
      case_when(
        year_of_birth <= 1929 ~ "pre-1930",
        year_of_birth <= 1939 ~ "1930s",
        year_of_birth <= 1949 ~ "1940s",
        year_of_birth <= 1959 ~ "1950s",
        year_of_birth <= 1969 ~ "1960s",
        year_of_birth <= 1979 ~ "1970s",
        year_of_birth <= 1989 ~ "1980s",
        year_of_birth <= 1999 ~ "1990s",
        TRUE ~ "unknown or error"
        
        
      )
  )|>
select(uniqueID, year_of_birth, decade_of_birth)
 #that gave me a 3 column table telling me the id for the politician, the year
#they were born, and which decade they were born in 

#summarise() lets me make new, condensed summary variables
#count() lets me count by groups
#class() lets me know what class some data is
#I can simulate data using seeds, like
set.seed(853)# which gets random numbers

#I can create my own functions using function(). let's say i need to create 
#a function that will print names

print_names <- function(some_names){print(some_names)}
print_names(c("woody", "buzz"))

#make graphs using ggplot2 (I already learned this)
#importing data in various formats, including tibbles (I already know this)
#use joins and pivots to arrange data


