# Wiki

Headers are not necessary for logins.

All request you do to the server that needs any authentication needs this header:
```
'token': '123...',
'username': 'user'
```
The wrong token or username will return the 401 error

### Pointers
- /drive/login (post) - log into the drive returns the token
- /drive/getfolders (get) - returns "folder": [], "files": []
- /drive/getimages (get) - returns the image array bytes
- /drive/createfolder (post) - create a folder in selected location
- /drive/uploadfile (post) - upload a file in selected folder
- /drive/delete (delete) - delete a folder or file selected

Success pointers will reset the DDOS protection, this is a ddos failure? yes!