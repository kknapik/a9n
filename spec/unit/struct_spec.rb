require "spec_helper"

describe A9n::Struct do
  context "without any values" do
    subject { described_class.new }

    describe "#empty?" do
      it { expect(subject).to be_empty }
    end

    describe "#keys" do
      it { expect(subject.keys).to eq([]) }
    end

    describe "#key?" do
      it { expect(subject.key?(:dwarf)).to eq(false) }
    end

    describe "#[]" do
      it { expect(subject[:dwarf]).to be_nil }
    end

    it "raises error on accessin invalid attribute" do
      expect {
        subject.dwarf
      }.to raise_error(A9n::NoSuchConfigurationVariable, "dwarf")
    end
  end

  context "with values" do
    subject {
      described_class.new({
          non_empty_dwarf: "dwarf",
          nil_dwarf:   nil,
          false_dwarf: false,
          true_dwarf:  true,
          hash_dwarf:  { dwarf: "hello" }
        })
    }

    describe "#keys" do
      it do
        expect(subject.keys).to eq [:non_empty_dwarf, :nil_dwarf, :false_dwarf, :true_dwarf, :hash_dwarf]
      end
    end

    describe "#key?" do
      it { expect(subject.key?(:nil_dwarf)).to eq(true) }
      it { expect(subject.key?(:unknown)).to eq(false) }
    end

    describe "#merge" do
      before { subject.merge(argument) }

      context "hash" do
        let(:argument) { { non_empty_dwarf: "hello dwarf" } }

        it do
          expect(subject.non_empty_dwarf).to eq("hello dwarf")
        end
      end

      context "struct" do
        let(:argument) { described_class.new(non_empty_dwarf: "hello dwarf") }

        it do
          expect(subject.non_empty_dwarf).to eq("hello dwarf")
        end
      end
    end

    it "is not empty" do
      expect(subject).not_to be_empty
    end

    it "gets non-empty value" do
      expect(subject.non_empty_dwarf).to eq("dwarf")
    end

    it "gets nil value" do
      expect(subject.nil_dwarf).to eq(nil)
    end

    it "gets true value" do
      expect(subject.true_dwarf).to eq(true)
    end

    it "gets false value" do
      expect(subject.false_dwarf).to eq(false)
    end

    it "gets hash value" do
      expect(subject.hash_dwarf).to be_kind_of(Hash)
    end

    it "raises exception when value not exists" do
      expect {
        subject.non_existing_dwarf
      }.to raise_error(A9n::NoSuchConfigurationVariable)
    end

    describe "#[]" do
      it "return non empty value" do
        expect(subject[:non_empty_dwarf]).to eq("dwarf")
      end

      it "return false value" do
        expect(subject[:false_dwarf]).to eq(false)
      end

      it "return nil value" do
        expect(subject[:nil_dwarf]).to eq(nil)
      end

      it "return nil for non existing value" do
        expect(subject[:non_existing_dwarf]).to eq(nil)
      end
    end
  end
end
