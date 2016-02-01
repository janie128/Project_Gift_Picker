# Data Source
### Main data source: Amazon customer reviews data
Data spanning May 1996 - July 2014 are available for download by request from [Dr. Julian McAuley, UCSD](http://jmcauley.ucsd.edu/data/amazon/).  
Data reviews from July 2014 onwards can be obtained by:  
1. Amazon’s API to acquire product metadata, in particular, the ASIN  
2. Web scraping of Amazon’s webpages to obtain reviews  
  
Examples of accessing Amazon's API and web scraping of reviews are included in `exploratory_analysis.R`.  
  
### Other data source:
Sentiment related words are removed from reviews during processing, as these do not contribute to keyword extraction to describe product.  
Dictionaries of positive and negative sentiment words are obtained from: [Hu and Liu's Opinion Lexicon](https://www.cs.uic.edu/~liub/FBS/sentiment-analysis.html#lexicon).  

#### References:  
"Image-based recommendations on styles and substitutes" J. McAuley, C. Targett, J. Shi, A. van den Hengel; *SIGIR*, 2015  
"Inferring networks of substitutable and complementary products" J. McAuley, R. Pandey, J. Leskovec; *Knowledge Discovery and Data Mining*, 2015  
"Mining and Summarizing Customer Reviews" M. Hu, B. Liu; *Proceedings of the ACM SIGKDD International Conference on Knowledge Discovery and Data Mining (KDD-2004)*, Aug 22-25, 2004, Seattle, Washington, USA
