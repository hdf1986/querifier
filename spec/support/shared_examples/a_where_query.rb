shared_examples "a where query" do
  describe '.where_attributes' do
    let!(:old_where_attributes) { described_class.where_attributes.dup }
    let(:fake_attributes) { [Time.now.to_i.to_s.to_sym] }
    before do
      stub_const 'FakeWhereClass', Class.new
      FakeWhereClass.class_eval{ include Querifier::Queries::Where }
    end

    after(:each) { described_class.where_attributes *old_where_attributes }

    it 'does not change if base class does' do
      expect { FakeWhereClass.where_attributes *fake_attributes }.not_to(
        change { described_class.where_attributes }
      )
    end

    it 'does not change if base class does' do
      expect { described_class.where_attributes *fake_attributes }.not_to(
        change { FakeWhereClass.where_attributes }
      )
    end
  end

  describe "#filter_by" do
    let(:query) { described_class.new(params) }

    before do
      allow(described_class.default_collection).to receive(:where)
      query.collection
    end

    context 'with an empty filter' do
      let(:params) { { filter: { where: { key: nil } } } }

      it 'doesn\'t call the where statement' do
        expect(query.collection).not_to have_received(:where)
      end
    end

    context 'with a fulfilled filter' do
      let(:params) { { filter: { where: { key: '1' } } } }

      it 'calls the where statement' do
        expect(query.collection).to have_received(:where)
      end
    end
  end

  described_class.where_attributes.each do |attr|
    describe "#filter_by_#{attr}" do
      let(:query) { described_class.new(params) }
      let(:params) { { filter: { where: { key: '1' } } } }
      subject(:filter_by) { query.send("filter_by_#{attr}", 1) }

      before do
        allow(query).to receive(:filter_by)
        filter_by
      end

      it 'calls filter_by' do
        expect(query).to have_received(:filter_by).with(attr, 1)
      end
    end
  end

  describe '#collection' do
    context 'with filter' do
      let(:query) { described_class.new(params) }
      subject(:collection) { query.collection }

      before do
        allow(query).to receive(:filter_by_key)
        allow(query).to receive(:filter_by_key_2)
        allow(query).to receive(:filter_by_non_enabled_key)
        collection
      end

      context 'with a simple filter key' do
        let(:params) { { filter: { where: { key: '1' } } } }

        it 'calls the filter_by_key statement with the correct params' do
          expect(query).to have_received(:filter_by_key).with('1')
        end
      end

      context 'with multiple valid filter key' do
        let(:params) { { filter: { where: { key: '1', key_2: '2'  } } } }

        it 'calls the filter_by_key statement with the key params' do
          expect(query).to have_received(:filter_by_key).with('1')
        end

        it 'calls the filter_by_key_2 statement with the second key params' do
          expect(query).to have_received(:filter_by_key_2).with('2')
        end
      end

      context 'with a non enabled filter key' do
        let(:params) { { filter: { where: { non_enabled_key: '1'} } } }

        it 'doesn\'t call the filter_by_non_enabled_key statement' do
          expect(query).not_to have_received(:filter_by_non_enabled_key)
        end
      end

      context 'with a empty enabled filter key' do
        let(:params) { { filter: { where: { key: ''} } } }

        it 'calls the filter_by_key statement with the key params' do
          expect(query).to have_received(:filter_by_key).with('')
        end
      end

      context 'with a nil enabled filter key' do
        let(:params) { { filter: { where: { key: nil} } } }

        it 'doesn\'t call the filter_by_non_enabled_key statement' do
          expect(query).not_to have_received(:filter_by_key)
        end
      end

      context 'with a non enabled filter key and a enabled key' do
        let(:params) { { filter: { where: { non_enabled_key: '1', key_2: '2'  } } } }

        it 'doesn\'t call the filter_by_non_enabled_key statement' do
          expect(query).not_to have_received(:filter_by_non_enabled_key)
        end

        it 'calls the filter_by_key_2 statement with the second key params' do
          expect(query).to have_received(:filter_by_key_2).with('2')
        end
      end

      context 'without a filter key' do
        let(:params) { { other_key: { where: { key: '1' } } } }

        it 'doesn\'t call the filter_by statement' do
          expect(query).not_to have_received(:filter_by_key)
        end
      end
    end
  end
end
