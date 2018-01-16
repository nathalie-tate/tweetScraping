# Tweet Scraping 

## Objective

The objective of this experiment was to build a model to detect transphobic,
hateful, and bigoted Tweets. Use cases of this model include automated blocking
scripts and content filtering.

## Data Collection and Analysis

Tweets were collected by streaming a search for the word "transgender" into a
text file using the *t* Twitter client. The search was run for seven days.
The resulting dataset contained 155,659 entries. Each entry contained the Tweet
ID, the username of the poster, the date it was posted, and the truncated
content of the tweet. ReTweets are denoted by the letters "RT" at the front of
the content. To reduce duplicate Tweets, the ReTweets were removed, leaving
26,958 entries remaining. 

The URL of a Tweet is in the format
`https://twitter.com/<user>/status/<tweetID>`. The Tweet IDs and usernames
were extracted from the dataset and used to compose a list of URLs. The full
HTML text of each page was then downloaded and the full content of the tweets
extracted.

## Categorization

In order to train any model, a sample set of Tweets must first be categorized
manually. The two categories chosen are ``Positive'' and ``Negative'', where a
negative Tweet is defined as any tweet that contains transphobic, hateful, or
bigoted language. Positive Tweets were defined as any Tweet that was not
negative. This includes Tweets that are neutral, off-topic, or in a language
other than English. 1,341 Tweets were categorized in this manner. Approximately 
70% of the classified Tweets were Positive.

## Model Building

Every Categorized Tweet had all punctuation removed. Other UTF-8 characters,
such as emojis, were left, because they could hold sentiment. Each Tweet was
then represented as a weighted tf-idf vector. The vectorized query Tweet was
then compared to every other Tweet using the Cosine Similarity Measure. The
average similarity to the positive Tweets was then compared to the average
similarity to the negative Tweets to determine the Tweet's classification. The
script then asks for user feedback to verify the correctness of the
classification. The Tweet is then correctly classified so that it can be used by
the model in the future.

## Results

The model was tested on 100 Tweets. The mode was able to correctly identify
positive Tweets much more often than negative Tweets. The confusion matrix of
the results is given below.

  | Positive | Negative
  --- | --- | ---
  Positive | 61 | 10
  Negative | 16 | 13

## Improvements and Future Work

There are a number of ways this model could be improved in the future. Stemming,
stop word analysis, and data stratification should all be considered.
Additionally, the model may improve if more Tweets are classified.

## Collected Tweets

The collected Tweets are not included for copyright reasons. Tweet collection
is left as an exercise for the reader 
