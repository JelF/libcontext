describe Context do
  pending 'threading'

  def variables
    subject.send(:variables)
  end

  describe 'set' do
    it 'does not set variable in parent context' do
      Context.set(a: 123) { Context[:b] = 456 }
      expect(Context[:a]).to be_nil
      expect(Context[:b]).to be_nil
    end

    it 'calls supplied block' do
      x = double
      expect(x).to receive(:message)

      Context.set(a: 123) { x.message }
    end

    context 'in Context a=123' do
      around do |example|
        Context.set(a: 123) { example.call }
      end

      it 'sets variable' do
        expect(Context[:a]).to eq(123)
      end

      it 'could be overriden' do
        Context[:a] = 456
        expect(Context[:a])
      end
    end
  end

  describe 'pluck' do
    specify 'zero variables' do
      x = Context.pluck { Context[:a] = 123 }
      expect(x).to be_nil
    end

    context 'one variable' do
      it 'returns it' do
        a = Context.pluck(:a) { Context[:a] = 123 }
        expect(a).to eq(123)
      end

      it 'does not return variable of double nested context' do
        a = Context.pluck(:a) { Context.set(a: 123) {} }
        expect(a).to be_nil
      end

      it 'does not return variable which was not overriden' do
        Context.set(a: 123) do
          a = Context.pluck(:a) { }
          expect(a).to be_nil
        end
      end
    end

    context 'three variables' do
      it 'returns both' do
        a, b, c = Context.pluck(:a, :b, :c) do
          Context[:a] = 123
          Context[:b] = 456
          Context[:c] = 789
        end

        expect(a).to eq(123)
        expect(b).to eq(456)
        expect(c).to eq(789)
      end

      it 'returns variables in right order even not all of them defined' do
        a, b, c = Context.pluck(:a, :b, :c) do
          Context[:a] = 123
          Context[:c] = 789
        end

        expect(a).to eq(123)
        expect(b).to eq(nil)
        expect(c).to eq(789)
      end
    end
  end

  describe '[]' do
    shared_examples 'it returns nil' do
      let(:key) { :key }

      it 'returns nil' do
        expect(subject[key]).to be_nil
      end
    end

    context 'when nothing with key present' do
      before { variables.delete(:key) }
      include_examples 'it returns nil'
    end

    context 'when no variable present' do
      before { variables[:key] = [] }
      include_examples 'it returns nil'
    end

    context 'when 2 values present' do
      before { variables[:key] = [123, 456] }
      it 'returns last value' do
        expect(subject['key']).to eq(456)
      end
    end
  end

  describe '[]=' do
    context 'when nothing with key present' do
      before { variables.delete(:key) }

      it 'sets variable' do
        subject['key'] = 123
        expect(variables[:key]).to eq [123]
      end
    end

    context 'when value with key is already present' do
      before { variables[:key] = [123] }

      context 'and new one is set' do
        before { subject[:key] = 456 }

        it 'pushes variable' do
          expect(variables[:key]).to eq [123, 456]
        end

        context 'and then variable is overriden' do
          before { subject[:key] = 789 }

          it 'changes value' do
            expect(variables[:key]).to eq [123, 789]
          end
        end
      end
    end
  end
end
