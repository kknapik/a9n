RSpec.describe A9n::Scope do
  subject { described_class.new(name) }

  describe '#name' do
    let(:name) { 'configuration' }

    it { expect(subject.name).to eq(:configuration) }
  end

  describe '#main?' do
    context 'when name is configuration' do
      let(:name) { 'configuration' }

      it { expect(subject).to be_root }
    end

    context 'when name is other than configuration' do
      let(:name) { 'google' }

      it { expect(subject).not_to be_root }
    end
  end

  describe '.form_file_path' do
    subject { described_class.form_file_path(path) }

    let(:path) { 'config/a9n/google.yml.example' }

    it { expect(subject.name).to eq(:google) }
  end
end
