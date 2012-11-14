module CapDeployRightscale
  class Credentials
    
    CREDENTIALS_FILE_PATH = './.cap_deploy_rightscale_credentials.json'

    def initialize()
      if File.exist?(CREDENTIALS_FILE_PATH)
        @credential_hash = JSON.parse(File.open(CREDENTIALS_FILE_PATH, "r").read)
      else
        @credential_hash = {}
      end
    end
    
    def add_credential(group, key, value)
      @credential_hash[group] = {} if not @credential_hash[group]
      @credential_hash[group][key] = value
    end
    
    def get_credential(group, key)
      return nil if not @credential_hash[group]
      return @credential_hash[group][key]
    end
    
    def save_file()
      File.open(CREDENTIALS_FILE_PATH, 'w') {|f| f.write(@credential_hash.to_json) }
    end
    
    def delete_file()
      File.delete(CREDENTIALS_FILE_PATH)
    end
    
  end
end