require "./spec_helper"

class MinionAPI::MockUser < MinionAPI::User
end

struct UserControllerTest < ART::Spec::APITestCase
  def test_add_positive : Nil
    target = {"count" => 3}
    self.request("GET", "/api/v1/user/count").body.should eq target.to_json
  end
end
