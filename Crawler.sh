#!/bin/bash

#aws s3 cp s3://crawlerinputbucket/home/ec2-user/hmsearch.config .
#aws s3 cp s3://crawlerinputbucket/home/ec2-user/hmscraper.config .

source /home/ec2-user/hmscraper.config
source /home/ec2-user/hmsearch.config

DB_HOST_NAME="${DatabaseHostName/$'\r'/}"
DATABASE_NAME="${DatabaseName/$'\r'/}"
TABLE_NAME="${TableName/$'\r'/}"
USERNAME="${Username/$'\r'/}"
PASSWORD="${Password/$'\r'/}"

while read line
do
     
	Firstpart=$(echo $line | sed 's/ *|.*//')  ####Fetches First part from hmsearch.config
        echo $FirstPart
	
	Secondpart=$(echo $line | sed 's/.*| *//') #### Fetches Second part from hmsearch.config 
	Type1=$(echo $Secondpart | sed 's/ *,.*//')  ##### Fetches Type
	Type=$(echo $Type1 | sed 's/.*= *//')
	echo $Type
	Source=$(echo $Secondpart | sed 's/.*= *//') #### Fetches Source
	echo $Source	
        
	URL_ARG=$(echo $Firstpart | sed 's/ /%20/g') #### Put %20 in place of Space in Parameter
        echo $URL_ARG
        wget -O output -U firefox http://www.hm.com/us/products/search?$URL_ARG
        grep -Po '(?<=href=")[^"]*' output > outputlinks  #### Fetching all Links from Page
       
	while read line1                #### Fetching Links from which data needs to be Crawled  
        do
                echo -e  "$line1 \n"
                grep "http://www.hm.com/us/product/" > sortedlinks
        done < outputlinks
	
	while read line2              #### Fetching Data from From sortedlinks  
	do
        	wget -O output -U firefox $line2

		#### Fetching ProductID

        	ProductID1="$line2";echo "${ProductID1##*/}" | sed 's/ *?.*//' > f2
		ProductID=$(cat f2)
        

		#### Fetching ProductName

        	< output tr -d '\n' | grep -oP '(?<=<ul class="breadcrumbs">).*?(?=</ul>)' >tempoutput1
        	< tempoutput1 tr -d '\n' | grep -oP '(?<=<strong>).*?(?=</strong>)' >temp1
        	ProductName1=$(cat temp1)
		ProductName="$(echo -e "${ProductName1}" | tr -d '[[:space:]]')"
        	echo $ProductName


		### Fetching ProductPrice

        	< output tr -d '\n' | grep -oP '(?<=<h1>).*?(?=</h1>)' >tempoutput2
        	< tempoutput2 tr -d '\n' | grep -oP '(?<=<span class="actual-price new">).*?(?=</span>)'>temp2
        	Productprice=$(cat temp2)
         	if [ "$ProductPrice" = "" ];then
                	< tempoutput2 tr -d '\n' | grep -oP '(?<=<span class="actual-price">).*?(?=</span>)'>temp2
                	ProductPrice=$(cat temp2)
                	echo $ProductPrice
         	fi

		#### Fetching ProductColor

        	< output tr -d '\n' | grep -oP '(?<=<span class="selected" id="text-selected-article">).*?(?=</span>)'>temp3
        	ProductColor=$(cat temp3| sed 's/ *\/.*//')
        	echo $ProductColor

		####Fetching ProductPattern

        	ProductPattern=$(cat temp3| sed -n -e 's/^.*\///p')
        	if [ "$ProductPattern" = "" ];then
                	ProductPattern="None"
        	fi
        	echo $ProductPattern


		#### Fetching Product Size
        	< output tr -d '\n' | grep -oP '(?<=<ul class="options variants clearfix" id="options-variants").*?(?=</ul>)'  >tempoutput4
        	< tempoutput4 tr -d '\n' | grep -oP '(?<=<span>).*?(?=</span>)'  >temp4
        	ProductSize=$(cat temp4)

		#### Fetching ProductImageURL

        	< output tr -d '\n' | grep -oP '(?<=<li class="act">).*?(?=</li>)' > tempoutput5
        	< tempoutput5 tr -d '\n' | grep -oP '(?<=<img src=").*?(?=")' > temp5
        	ProductImageURL=$(cat temp5)

		#### Fetching Product URL

        	ProductURL=$line2
        	echo $line2

		mysql -h $DB_HOST_NAME -u $USERNAME -p$PASSWORD -e "insert into $TABLE_NAME values ('$ProductID','$ProductImageURL','$ProductName','$ProductColor','$ProductPattern','$ProductSize','$ProductPrice','$ProductURL','$Type','$Source')" "$DATABASE_NAME" 


	done < sortedlinks

done < hmsearch.config

















