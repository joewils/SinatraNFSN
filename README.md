# SinatraNFSN

Example [Sinatra](http://www.sinatrarb.com) app for [NearlyFreeSpeech.net](https://www.nearlyfreespeech.net) (NFSN) using the Puma webserver.

## Installing

Create a site at NFSN of the type Apache 2.4 Generic. Enable SSH access if it's not already activated, and SSH into the site to execute the following commands:

```bash
cd /home/protected/
git clone --depth=1 https://github.com/joewils/SinatraNFSN.git
cd SinatraNFSN
bundle config set --local path '/home/private//.gem'
# if the above doesn't work try this:
# bundle config set path 'vendor/bundle'
bundle install
```

In the NFSN site control panel, add a daemon with these settings:

- Tag: `sinatra`
- Command Line: `/home/protected/SinatraNFSN/run.sh`
- Working Directory: `/home/protected/SinatraNFSN/`
- Run Daemon As: `me`

Add a proxy with the default settings:

- Protocol: `HTTP`
- Base URI: `/`
- Document Root: `/`
- Target Port: `8080`

That's it! The daemon will start automatically after it's created. If there are no problems, you should see the dashboard at the site's web address.

## SQLite Database

The app includes a SQLite database (`nfsn.db`) populated from CSV files in the `contoso/` folder. To seed or reset the database:

```bash
bundle exec ruby db/seed.rb
```

### Routes

| Route | Description |
|-------|-------------|
| `/` | Dashboard with table counts |
| `/customers` | Customer list (paginated) |
| `/stores` | Store list (paginated) |
| `/products` | Product list (paginated) |
| `/orders` | Order list (paginated) |
| `/order_rows` | Order line items (paginated) |
| `/dates` | Date dimension table (paginated) |
| `/currency` | Currency exchange rates (paginated) |

## Troubleshooting

Check the file `/home/logs/daemon_sinatra.log` for log and error messages. Most importantly, make sure the daemon is running as "me" *not* "web". Otherwise, Ruby will fail to find the right gems and give an error on starting the server. Also check that the proxy port is the same as what Sinatra/Puma is listening on.

The app might break on NFSN realm updates. If you're getting errors about an incorrect bundler version, even when running `bundle update --bundler`, try deleting Gemfile.lock and running `bundle install` again.

## License

This code is made available under the [MIT license](LICENSE). Feel free to use and adapt it however you see fit.
