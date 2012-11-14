require 'spec_helper'

describe 'CapDeployRightscale::Credentials' do
  
  it 'should be able to initialize with no file' do
    credentials = CapDeployRightscale::Credentials.new
    credentials.should_not be_nil
  end
  
  it 'should be able to add/get a credential' do
    credentials = CapDeployRightscale::Credentials.new
    credentials.add_credential('test_group', 'name', 'Dennis')
    credentials.get_credential('test_group', 'name').should eq('Dennis')
  end
  
  it 'should be able to persist credentials' do
    credentials = CapDeployRightscale::Credentials.new
    credentials.add_credential('test_group', 'name', 'Dennis')
    credentials.get_credential('test_group', 'name').should eq('Dennis')
    credentials.save_file
    
    credentials = CapDeployRightscale::Credentials.new
    credentials.get_credential('test_group', 'name').should eq('Dennis')
    
    credentials.delete_file
    
    credentials = CapDeployRightscale::Credentials.new
    credentials.get_credential('test_group', 'name').should be_nil
  end
  
end