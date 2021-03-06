require 'spec_helper'

describe Locomotive::API::Resources::VersionResource do

  include Rack::Test::Methods

  describe 'GET /jl/api/v3/version.json' do
    context 'JSON' do
      subject { parsed_response }

      it 'returns the current engine version' do
        get '/jl/api/v3/version.json'
        expect(subject).to eq({ "engine" => Locomotive::VERSION })
      end

    end
  end

end
