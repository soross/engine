# encoding: utf-8

describe Locomotive::Middlewares::Site do

  let(:site)        { create('existing site', domains: ['http://localhost']) }
  let(:url)         { 'http://localhost/jl/models' }
  let(:app)         { ->(env) { [200, env, 'app'] } }
  let(:middleware)  { described_class.new(app) }

  subject { code, env = middleware.call(env_for(url)); env['locomotive.site'] }

  describe 'no site' do

    let(:app) { ->(env) { raise ::Locomotive::Steam::NoSiteException.new } }

    it { is_expected.to eq(nil) }

    describe 'not the default host' do

      before { allow(Locomotive::Account).to receive(:count).and_return(1) }

      let(:warden)    { instance_double('WargenStrategy', authenticate: nil) }
      let(:rack_env)  { env_for(url).tap { |e| e['warden'] = warden } }

      subject { middleware.call(rack_env) }

      it { expect(subject.first).to eq 404 }
      it { expect(subject.last.body).to match(/Site not found \| jl/) }

      it 'has to escape the host to prevent XSS attacks (by setting the X-Forwarded-Host header)' do
        allow_any_instance_of(ActionDispatch::Request).to receive(:host).and_return('<script>alert(1)</script>')
        expect(subject.last.body).not_to include('<script>alert(1)</script>')
      end

      context 'default host' do

        before { allow(Locomotive.config).to receive(:host).and_return('example.com') }

        it { expect(subject.first).to eq 301 }
        it { expect(subject[1]['Location']).to eq '/jl/sign_in' }

      end

    end

  end

  describe 'no account' do

    let(:app) { ->(env) { raise ::Locomotive::Steam::NoSiteException.new } }

    subject { middleware.call(env_for(url)) }

    it { expect(subject.first).to eq 301 }

    context 'default config' do
      it { expect(subject[1]['Location']).to eq '/jl/sign_up' }
    end

    context 'config enable_registration set to false' do

      before { allow(Locomotive.config).to receive(:enable_registration).and_return(false) }

      it { expect(subject[1]['Location']).to eq '/jl/sign_in' }
    end

  end

  describe 'requesting the back-office assets' do

    before { site }
    before { allow(middleware).to receive(:default_host).and_return('steve.me') }

    let(:url) { 'http://localhost/assets/foo.png' }
    it { is_expected.to eq(nil) }

    context 'localhost' do

      let(:url) { 'http://localhost/assets/foo.png' }
      it { is_expected.to eq(nil) }

    end

    context '0.0.0.0' do

      let(:url) { 'http://0.0.0.0/assets/foo.png' }
      it { is_expected.to eq(nil) }

    end

  end

  describe 'the requested site is also the default host' do

    before { site }
    before { allow(middleware).to receive(:default_host).and_return('steve.me') }

    context 'home page' do

      let(:url) { 'http://localhost' }
      it { expect(subject.name).to eq('Locomotive site with existing models') }

    end

    context 'about page' do

      let(:url) { 'http://localhost/about' }
      it { expect(subject.name).to eq('Locomotive site with existing models') }

    end

    context 'locomotive app section' do

      let(:url) { 'http://localhost/jl/sites' }
      it { is_expected.to eq(nil) }

    end

  end

  describe 'existing site' do

    before { site }

    it { expect(subject.name).to eq('Locomotive site with existing models') }
    it { expect(subject.handle).to eq('models') }

    context 'fetching from the host' do

      let(:url) { 'http://localhost/about' }

      it { expect(subject.name).to eq('Locomotive site with existing models') }

    end

  end

end
