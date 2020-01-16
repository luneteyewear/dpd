# DPD (Shipping Web API) 📦

Ruby SDK for working with [DPD](https://api.dpd.ro/web-api.html) Web API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dpd'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dpd

## Usage

A subset of the DPD resources are provided with this SDK:

 * `DPD::Shipment`
 * `DPD::Printout`
 * `DPD::Voucher`
 * `DPD::Pickup`
 * `DPD::Track`

These resources have implemented the following methods to allow API operations:
 * `find`
 * `create`

Here's an example on how to create a shipment, request it's pickup and cancel
it.
```ruby
require 'dpd'

shipment = DPD::Shipment.create(
  service: {
    serviceId: ENV['DPD_SERVICE_ID'],
    autoAdjustPickupDate: true,
    saturdayDelivery: true
  },
  payment: { courierServicePayer: 'SENDER' },
  ref1: 'LNT_ORDER_ID',
  sender: { clientId: 'DPD_CLIENT_ID' },
  recipient: {
    privatePerson: true,
    contactName: 'Lunet Studio SRL',
    clientName: 'Lunet Studio SRL',
    phone1: {
      number: '+40728547184'
    },
    address: {
      countryId: ENV['DPD_COUNTRY_ID'],
      siteName: 'Bucharest',
      addressNote: 'Bld. Lascar Catargiu 15A, 12, Sector 1, 010661 Bucharest',
      addressLine1: 'Bld. Lascar Catargiu 15A, 12',
      addressLine2: 'Sector 1, 010661 Bucharest',
      postCode: '010661'
    }
  },
  content: {
    parcelsCount: 1,
    totalWeight: 0.5,
    contents: 'GLASSES',
    package: 'BOX'
  }
)

DPD::Pickup.create(
  explicitShipmentIdList: [shipment.id],
  visitEndTime: '19:00'
)

shipment.cancel('Customer request.')
```

### Configuration

The API keys will be loaded from your environment variables:

 * `DPD_USERNAME`
 * `DPD_PASSWORD`

Please remember, DPD will provide you separately with a **DPD_CLIENT_ID**,
**DPD_SERVICE_ID** and the **DPD_COUNTRY_ID**, based on your location and the
type of services you opted for.

## Development

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/luneteyewear/dpd. This project is intended to be a safe,
welcoming space for collaboration, and contributors are expected to adhere to
the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT
License](https://opensource.org/licenses/MIT).
