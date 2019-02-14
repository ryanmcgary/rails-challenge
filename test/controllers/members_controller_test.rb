require 'test_helper'

class MembersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @member = members(:one)
  end

  test "create" do
    assert_difference('Member.count') do
      post members_url, params: { member: { name: @member.name, url: @member.url } }
    end

    assert_redirected_to member_url(Member.last)
  end

  test "update" do
    patch member_url(@member), params: { member: { name: @member.name, url: @member.url } }
    assert_redirected_to member_url(@member)
  end

  test "destroy" do
    assert_difference('Member.count', -1) do
      delete member_url(@member)
    end

    assert_redirected_to members_url
  end
end
