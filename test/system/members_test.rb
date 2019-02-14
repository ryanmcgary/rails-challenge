require "application_system_test_case"

class MembersTest < ApplicationSystemTestCase
  setup do
    @member = members(:one)
  end

  test "create" do
    visit members_url
    click_on "New Member"

    fill_in "Name", with: @member.name
    fill_in "Url", with: @member.url
    click_on "Create Member"

    assert_text "Member was successfully created"
    click_on "Back"
  end

  test "update" do
    visit members_url
    click_on "Edit", match: :first

    fill_in "Name", with: @member.name
    fill_in "Url", with: @member.url
    click_on "Update Member"

    assert_text "Member was successfully updated"
    click_on "Back"
  end

  test "destroy" do
    visit members_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Member was successfully destroyed"
  end
end
