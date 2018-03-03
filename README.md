# My Ledger

**My Ledger** is an application to help you keep track of your expenses.
You will feed it with your credit card statements and you can categorize every purchase you made to see how you're spending your money.
Work in progress.

# Technical

## To do
- Add a mailer on Heroku
- Add React

## Notes for developer

### Generate Branch Name
```
"<string>".downcase.gsub(/[ \:\-]+/, '_').gsub(/\W/, '').underscore
```
For GitHub issue, prefix by `iX-`
For Rollbar issue, prefix by `rX-`

### Assets
Assets are precomplied and a diggest will be appended for versionning. Check [Coding Links to Assets](http://guides.rubyonrails.org/asset_pipeline.html#coding-links-to-assets) for more details.
- Create ab image tag: `<%= image_tag "icons/rails.png" %>`
- ERB: `background-image: url(<%= asset_path 'image.png' %>)`
- [SASS/SCSS](http://guides.rubyonrails.org/asset_pipeline.html#css-and-sass): `background-image: image-url("rails.png")`

## Useful commands

### Heroku

Publish a branch to Heroku:
`git push -f heroku <branch_name>:master`

Open a rails console:
`heroku.cmd run rails c`

Open bash:
`heroku.cmd run bash`
NOTE: requires to close any open rails console when using the free version (limited to only 1 connection opened)
