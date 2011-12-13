ls *.htm | sed 's/.*/php & | grep -v "Warning:" > phparsed\/&/' | bash
cp *css phparsed/
s3cmd sync --acl-public --guess-mime-type phparsed/ s3://www.adamgginsburg.com/ &
