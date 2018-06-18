                     ################################
			      H&M Crawling
		     #################################

Before moving to the execution,I would like to explain all the files that are needed to run this script.All files are stored in BitBucket directory and are as follows

(a)Crawler.sh ----------> Script file which do the crawling and storing data to database

(b)hmsearch.config -----> All search parameters are stored in this config file

(c)hmscraper.config ----> Databasehostname,database name,credentials etc are stored in it.

(d)spot.py  ------------> A python file which request spot request.

(e)config.json ---------> A json file which contains arguments for spot.py file

(f)config1.json --------> A json file which contains arguments for spot.py file

(g).boto ---------------> .boto file contains Credentials for connecting with ec2 instance

Runnig a H&M Crawling

(1)Create a Database instance with Amazon Relational Database System(RDS).And
save your hostname which will be used to connect with Database instance.Define your database schema on Amazon RDS.
(2)Setup your Amazon S3 bucket and put your script and configuration files on
it.
(3)Create a EC2 instance according to your requirement.
(4)Fetching all files from S3 Bucket on EC2 instance.
(5)Setting up crontab for your Crawler script on EC2 instance.
(6)Take AMI and take ami-id,snapshot-id of EC2 instance and stop that instance.
(7)Enter that AMI id nd snapshot-id in conf.json file.
(8)Run spot.py which use conf.json as an argument for creating ec2 instance
with spot request using boto commandline.

	


