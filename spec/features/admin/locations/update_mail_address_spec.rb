require 'rails_helper'

feature 'Updating mailing address' do
  before(:each) do
    @location = create(:location)
    login_super_admin
    visit '/admin/locations/vrs-services'
  end

  scenario 'adding a new mailing address with valid values', :js do
    add_mailing_address(
      attention: 'moncef',
      address_1: '123',
      city: 'Vienna',
      state_province: 'VA',
      postal_code: '12345',
      country: 'US'
    )
    visit '/admin/locations/vrs-services'

    expect(find_field('location_mail_address_attributes_attention').value).
      to eq 'moncef'
    expect(find_field('location_mail_address_attributes_address_1').value).
      to eq '123'
    expect(find_field('location_mail_address_attributes_city').value).
      to eq 'Vienna'
    expect(find_field('location_mail_address_attributes_state_province').value).
      to eq 'VA'
    expect(find_field('location_mail_address_attributes_postal_code').value).
      to eq '12345'

    remove_mail_address
    visit '/admin/locations/vrs-services'
    expect(page).to have_link 'Add a mailing address'
  end

  scenario 'when leaving location without address or mail address', :js do
    remove_street_address
    expect(page).
      to have_content "Unless it's virtual, a location must have an address."
  end
end

feature 'Updating mailing address with invalid values' do
  before(:all) do
    @location = create(:mail_address).location
  end

  before(:each) do
    login_super_admin
    visit '/admin/locations/no-address'
  end

  after(:all) do
    Organization.find_each(&:destroy)
  end

  scenario 'with an empty street' do
    update_mailing_address(address_1: '', city: 'fair', state_province: 'VA',
                           postal_code: '12345', country: 'US')
    click_button 'Save changes'
    expect(page).to have_content "address 1 can't be blank for Mail Address"
  end

  scenario 'with an empty city' do
    update_mailing_address(address_1: '123', city: '', state_province: 'VA',
                           postal_code: '12345', country: 'US')
    click_button 'Save changes'
    expect(page).to have_content "city can't be blank for Mail Address"
  end

  scenario 'with an empty state' do
    update_mailing_address(address_1: '123', city: 'fair', state_province: '',
                           postal_code: '12345', country: 'US')
    click_button 'Save changes'
    expect(page).to have_content t('errors.messages.invalid_state_province')
  end

  scenario 'with an empty zip' do
    update_mailing_address(address_1: '123', city: 'Belmont', state_province: 'CA',
                           postal_code: '', country: 'US')
    click_button 'Save changes'
    expect(page).to have_content "postal code can't be blank for Mail Address"
  end

  scenario 'with an empty country' do
    update_mailing_address(address_1: '123', city: 'Belmont', state_province: 'CA',
                           postal_code: '12345')
    click_button 'Save changes'
    expect(page).to have_content "country can't be blank for Mail Address"
  end

  scenario 'with an invalid state' do
    update_mailing_address(address_1: '123', city: 'Par', state_province: 'V',
                           postal_code: '12345', country: 'US')
    click_button 'Save changes'
    expect(page).to have_content t('errors.messages.invalid_state_province')
  end

  scenario 'with an invalid zip' do
    update_mailing_address(address_1: '123', city: 'Ald', state_province: 'VA',
                           postal_code: '1234', country: 'US')
    click_button 'Save changes'
    expect(page).to have_content 'valid ZIP code'
  end

  scenario 'with an invalid country' do
    update_mailing_address(address_1: '123', city: 'Ald', state_province: 'VA',
                           postal_code: '12345', country: 'U')
    click_button 'Save changes'
    expect(page).to have_content 'too short'
  end
end
