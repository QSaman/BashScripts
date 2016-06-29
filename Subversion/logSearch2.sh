svn log http://192.168.141.200/java/BMI/trunk
 
| grep -i -B3 -A1 btbmi-108 | grep -E 'r[0-9]{1,} \| saadi' | sort | cut -d" " -f1 | paste -sd ','