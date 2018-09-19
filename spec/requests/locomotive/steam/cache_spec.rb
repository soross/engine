# encoding: utf-8

describe Locomotive::Steam::Middlewares::Cache do

  let(:site_cache)  { false }
  let(:page_cache)  { false }
  let(:site)        { instance_double('CacheSite', _id: '0001', cache_enabled: site_cache, last_modified_at: DateTime.parse('2007/06/29 00:00:00')) }
  let(:page)        { instance_double('CachedPage', _id: '0042', cache_enabled: page_cache, redirect_url: nil) }
  let(:app)         { ->(env) { [200, env, 'app'] } }
  let(:middleware)  { described_class.new(app) }
  let(:steam_env)   { { 'Content-Type' => 'text/html', 'REQUEST_METHOD' => 'GET', 'steam.site' => site, 'steam.page' => page, 'steam.live_editing' => false, 'PATH_INFO' => 'foo', 'QUERY_STRING' => 'a=1&c=3' } }

  describe '#call' do

    subject { middleware.call(env_for('foo', steam_env)) }

    it { expect(subject.first).to eq 200 }

    context 'cache enabled' do

      before(:each) { Rails.cache.clear }

      let(:site_cache) { true }
      let(:page_cache) { true }

      it { expect(subject.first).to eq 200 }

      it 'does not go to the next middleware' do
        middleware.call(env_for('foo', steam_env)) # warm up the cache
        expect(middleware.app).not_to receive(:call)
        expect(subject.first).to eq 200
        expect(subject[1]['Content-Type']).to eq 'text/html'
      end

    end

  end

  describe '#cache_key' do

    subject { middleware.send(:cache_key, steam_env) }

    it { expect(subject).to eq '09116b689697659d33bf61f39839ee06' }

  end

  describe '#cacheable?' do

    subject { middleware.send(:cacheable?, steam_env) }

    let(:live_editing) { true }
    it { expect(subject).to eq false }

    context 'live editing off' do

      let(:live_editing) { false }
      it { expect(subject).to eq false }

      context 'cache enabled for site' do

        let(:site_cache) { true }
        it { expect(subject).to eq false }

        context 'cache enabled for page' do

          let(:page_cache) { true }
          it { expect(subject).to eq true }

          context 'POST method' do

            let(:steam_env) { { 'REQUEST_METHOD' => 'POST', 'steam.site' => site, 'steam.page' => page, 'steam.live_editing' => false, 'PATH_INFO' => 'foo' } }
            it { expect(subject).to eq false }

          end

          context 'page is a redirection' do

            let(:page) { instance_double('CachedPage', _id: '0042', cache_enabled: page_cache, redirect_url: 'http://localhost') }
            it { expect(subject).to eq false }

          end

        end

      end

    end

  end

end
