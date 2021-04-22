# eulerity-takehome-async-images

## Display a list of images:
* Make a GET request to /image to retrieve an array of JSON objects. The JSON object will contain an “url” attribute pointing to a target image.
* Images should be loaded asynchronously
## Allow editing of an image
* Allow user to apply a filter
* Allow user to overlay text
* Allow some other interesting image edits.. be creative
## Save the image
* Make a GET request to /upload which will return a JSON object with a "url" attribute to which the image can be uploaded.
* Upload the edited image file to the given url, using a POST request with a multipart/form-data encoding type. The form should include the following fields:
  appid: a string unique to your project (e.g. your email address)
  original: the url of the original image the user edited
  file: the image file being uploaded
