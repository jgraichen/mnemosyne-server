# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ::Server::Pipeline::Metadata::Rails::ActiveJob do
  let(:payload) do
    {
      meta: {
        worker: 'ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper'
      },
      span: [{
        name: 'example.trace.mnemosyne'
      }, {
        name: 'app.job.perform.active_job',
        meta: {
          id: '141b17b8-7d59-414d-b8c0-fa50dcb76e41',
          job: 'MyActiveJob',
          arguments: [1, 2, 3],
          queue: 'default'
        }
      }]
    }
  end

  let(:el) { described_class }

  subject { el.call(payload) {|env| return env } }

  it 'extracts job information' do
    expect(subject[:meta]).to eq worker: 'MyActiveJob'
  end
end
