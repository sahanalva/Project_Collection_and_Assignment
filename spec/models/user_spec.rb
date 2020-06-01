  require 'rails_helper'

describe User, type: :model do
  it 'should create a new instance of a user given valid attributes' do
    User.create!(firstname: 'David', lastname: 'Smith',email: 'david@xyz.com', personal_email: 'david@xyz.com',password: '1234567', uin: '456728360', semester: 'Fall', year: '2016', course: 'csce606')
    User.create!(firstname: 'Andy', lastname: 'Smith',email: 'andy@xyz.com', personal_email: 'andy@xyz.com', password: '1234567', uin: '456728361', semester: 'Fall', year: '2016', course: 'csce606')
  end
end
