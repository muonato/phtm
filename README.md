# phtm

Creates a printer-friendly picture gallery HTML by reading picture filenames in CSV file. Contents page writer for images described in CSV file and exported to gallery folder.

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
Requirements:
```
	ImageMagick package for picture verification (identify) and orientation (convert).
	
	$ apt info imagemagick
```
