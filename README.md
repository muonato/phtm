# phtm

Creates a printer-friendly picture gallery HTML by reading picture filenames in CSV file. Used for creating a contents page of images exported to gallery folder. 

ImageMagick is required for picture verification (identify) and orientation (convert).

Arguments:
```
	$1 - path to CSV file
	$2 - delimiter character used in CSV file, default ','
	$3 - filename column number in CSV file, default '0'
	$4 - path to picture gallery folder, default './'
	$5 - output filename, default 'index.html'
```
Examples:
```
	$ phtml.sh photos.csv
	$ phtml.sh images.csv , 1 ./images images.html
```
