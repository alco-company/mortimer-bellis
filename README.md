# README

Mortimer Time & Attendance (MTA) is a lean take on the centuries old 'punch clock'. You get a back office
with accounts, users, locations, punch_clocks, teams, employees, and you get a front office with
punch_cards, and punches.

MTA will email you a summary every morning at 05:00 highlighting what is important - employees working more than what has been
agreed with them, employees working less, and employees not been working at all.

MTA will allow you to pull essential payroll data when your next payroll data contribution date nears.

## REFERENCES

See [the references](REFERENCES.md) for a detailed list of all the contributors to open source that has had an impact on the
realization of this product.

## Installation

You may install MTA by following this _recipe_

```shell
$ git clone https://github.com/alco-company/mortimer-bellis.git
$ ...
```

You may spin up MTA on your local host with `dev` and hit https://localhost:3000 in your browser - it will
respect SSL.

Deploying MTA with [Kamal](https://kamal-deploy.org/) on a hosting platform like [Hetzner](https://hetzner.com) is
as easy as can be - follow [this guide](https://dev.to/adrienpoly/deploying-a-rails-app-with-mrsk-on-hetzner-a-beginners-guide-39kp)

## Usage

Out of the box MTA will seed your database (it defaults to SQLite3 in the spirit of current Rails philosophy) with a
small dataset. All you have to do is sign up - with the first user being a 'superuser'

### Configuration

There are a number of configuration options at your disposal.
...