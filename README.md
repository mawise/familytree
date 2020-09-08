# Family Tree

I tried using Gramps, but it was too complex so I wrote my own?

## Deployment Notes

* Deploy as a standard rails app. Uses SQlite even in production

* Currently uses `dotenv` to store config in a dot file

* Expects S3 storage (for image uploads), specify bucket in `.env` file

* You need to manually create user accounts from the rails console:
  * `User.create! email: "user@email.com", password:"123456"`

* Uses graphviz for generating graphs, make sure your system has graphviz installed 
