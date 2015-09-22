describe Context::Query do
  let(:context) { double(:context) }
  subject { described_class.new(context) }

  shared_examples 'it releases itself' do
    let(:block) { -> {} }

    before do
      expect(context).to receive(:release!).with(subject, block)
    end
  end

  describe 'set' do
    context 'a=1, b=2' do
      before { subject.set(a:1, b:2) }
      specify { expect(subject.sets).to match(a:1, b:2) }
      context 'and then b=3, c=4' do
        before { subject.set(b:3, c:4) }
        specify { expect(subject.sets).to match(a:1, b:3, c:4)}
      end
    end

    it_behaves_like 'it releases itself' do
      specify { subject.set(&block) }
    end
  end

  describe 'pluck' do
    shared_examples 'it could be iterated in right order' do
      it 'could be iterated in right order' do
        expect(subject.plucks.each.to_a).to eq(expectation)
      end
    end

    context 'a and b' do
      before { subject.pluck(:a, :b) }

      it_behaves_like 'it could be iterated in right order' do
        let(:expectation) { %i[a b] }
      end

      context 'then a and c' do
        before { subject.pluck(:a, :c) }

        it_behaves_like 'it could be iterated in right order' do
          let(:expectation) { %i[a b c] }
        end
      end
    end

    it_behaves_like 'it releases itself' do
      specify { subject.pluck(&block) }
    end
  end
end
