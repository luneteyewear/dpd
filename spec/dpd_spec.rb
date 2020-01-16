require 'spec_helper'

RSpec.describe DPD do
  let(:dpd_parcel_id) { 80_147_286_562 }
  let(:sender) { 'Lunet Studio SRL' }
  let(:address) { 'Bld. Lascar Catargiu 15A, 12, Sector 1, 010661 Bucharest' }
  let(:zip) { '010661' }
  let(:shipment_data) do
    {
      service: {
        serviceId: ENV['DPD_SERVICE_ID'],
        autoAdjustPickupDate: true,
        saturdayDelivery: true
      },
      payment: { courierServicePayer: 'SENDER' },
      ref1: 'LNT_ORD_ID',
      sender: { clientId: ENV['DPD_CLIENT_ID'] },
      recipient: {
        privatePerson: true,
        contactName: sender,
        clientName: sender,
        phone1: {
          number: '+40728547184'
        },
        address: {
          countryId: 642,
          siteName: 'Bucharest',
          addressNote: address[0..200],
          addressLine1: address[0..40],
          addressLine2: address[40..80],
          postCode: zip
        }
      },
      content: {
        parcelsCount: 1,
        totalWeight: 0.5,
        contents: 'GLASSES',
        package: 'BOX'
      }
    }
  end
  let(:shipment) do
    DPD::Shipment.create(shipment_data)
  end
  let(:vcr_cassette) { 'dpd_create' }

  before { VCR.insert_cassette(vcr_cassette) }

  after { VCR.eject_cassette(vcr_cassette) }

  it do
    expect(shipment).to be_a(DPD::Shipment)
    expect(shipment.id).to eq(dpd_parcel_id.to_s)
    expect(shipment.parcels.size).to eq(1)
  end

  describe '#find' do
    let(:comment) { 'Customer request.' }
    let(:shipment) { DPD::Shipment.find(dpd_parcel_id) }
    let(:vcr_cassette) { 'dpd_find' }

    context 'on error' do
      let(:dpd_parcel_id) { 'wrong' }
      let(:vcr_cassette) { 'dpd_error' }

      it do
        expect { shipment }.to raise_error(
          HTTP::RestClient::ResponseError,
          'Barcode wrong not found'
        )
      end
    end
  end

  describe '#cancel' do
    let(:comment) { 'Customer request.' }
    let(:shipment) { DPD::Shipment.find(dpd_parcel_id) }
    let(:vcr_cassette) { 'dpd_cancel' }

    it do
      expect(shipment.cancel(comment)).to eq({})
    end
  end
end
