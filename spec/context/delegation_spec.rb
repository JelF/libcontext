describe Context::Delegation do
  describe 'delegate' do
    extend Context::Delegation
    let(:variable) { '123' }

    describe 'to argument' do
      subject { to_i }

      context 'target is symbol' do
        delegate :to_i, to: :variable
        it { is_expected.to eq(123) }
      end

      context 'target is proc' do
        delegate :to_i, to: proc { variable }
        it { is_expected.to eq(123) }
      end

      context 'target is lambda' do
        delegate :to_i, to: -> { variable }
        it { is_expected.to eq(123) }
      end

      context 'target is something else' do
        delegate :to_i, to: '123'
        it { is_expected.to eq(123) }
      end
    end

    describe 'prefix argument' do
      subject { self }

      context 'prefix is false' do
        delegate :to_i, to: :variable
        it { is_expected.to respond_to(:to_i) }
      end

      context 'prefix is true' do
        delegate :to_i, to: :variable, prefix: :prefix
        it { is_expected.to respond_to(:prefix_to_i) }
      end
    end

    context 'block in call' do
      let(:variable) { [1, 3] }
      delegate :any?, to: :variable

      it 'passes block' do
        expect(any?(&:even?)).to be_falsey
      end
    end
  end
end
