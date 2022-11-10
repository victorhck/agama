# frozen_string_literal: true

# Copyright (c) [2022] SUSE LLC
#
# All Rights Reserved.
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of version 2 of the GNU General Public License as published
# by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, contact SUSE LLC.
#
# To contact SUSE LLC about this file by physical or electronic mail, you may
# find current contact information at www.suse.com.

require_relative "../../test_helper"
require "dinstaller/storage/proposal"
require "dinstaller/config"

describe DInstaller::Storage::Proposal do
  subject(:proposal) { described_class.new(logger, config) }

  let(:logger) { Logger.new($stdout, level: :warn) }
  let(:config) { DInstaller::Config.new(config_data) }
  let(:y2storage_proposal) { instance_double(Y2Storage::GuidedProposal, failed?: failed) }
  let(:y2storage_manager) do
    instance_double(Y2Storage::StorageManager, probed: nil, probed_disk_analyzer: nil)
  end
  let(:failed) { false }
  let(:config_data) { {} }

  describe "#calculate" do
    before do
      allow(Y2Storage::StorageManager).to receive(:instance).and_return y2storage_manager
      allow(Y2Storage::GuidedProposal).to receive(:initial).and_return y2storage_proposal
      allow(y2storage_manager).to receive(:proposal=)
    end

    context "when there is no 'volumes' section in the config" do
      let(:config_data) { {} }

      it "calculates the Y2Storage proposal with a default set of VolumeSpecification" do
        expect(Y2Storage::GuidedProposal).to receive(:initial) do |**args|
          expect(args[:settings]).to be_a(Y2Storage::ProposalSettings)
          vols = args[:settings].volumes
          expect(vols).to_not be_empty
          expect(vols).to all(be_a(Y2Storage::VolumeSpecification))

          y2storage_proposal
        end

        proposal.calculate
      end
    end

    context "when there is a 'volumes' section in the config" do
      let(:config_data) do
        { "storage" => { "volumes" => [{ "mount_point" => "/one" }, { "mount_point" => "/two" }] } }
      end

      it "calculates the Y2Storage with the correct set of VolumeSpecification" do
        expect(Y2Storage::GuidedProposal).to receive(:initial) do |**args|
          expect(args[:settings]).to be_a(Y2Storage::ProposalSettings)
          vols = args[:settings].volumes
          expect(vols).to all(be_a(Y2Storage::VolumeSpecification))
          expect(vols.map(&:mount_point)).to contain_exactly("/one", "/two")

          y2storage_proposal
        end

        proposal.calculate
      end
    end

    context "when the Y2Storage proposal successes" do
      let(:failed) { false }

      it "saves the proposal" do
        expect(y2storage_manager).to receive(:proposal=).with y2storage_proposal
        proposal.calculate
      end
    end

    context "when the Y2Storage proposal fails" do
      let(:failed) { true }

      it "does not save the proposal" do
        allow(y2storage_manager).to receive(:staging=)
        expect(y2storage_manager).to_not receive(:proposal=)
        proposal.calculate
      end
    end
  end

  describe "#validate" do
    let(:sda) { instance_double(Y2Storage::Device, display_name: "/dev/sda") }
    let(:available_devices) { [sda] }
    let(:candidate_devices) { ["/dev/sda"] }

    before do
      allow(subject).to receive(:available_devices).and_return(available_devices)
      allow(subject).to receive(:candidate_devices).and_return(candidate_devices)
      allow(subject).to receive(:proposal).and_return(y2storage_proposal)
    end

    context "when the proposal was successful" do
      let(:failed) { false }

      it "returns an empty list" do
        expect(subject.validate).to eq([])
      end
    end

    context "when the proposal does not exist yet" do
      let(:y2storage_proposal) { nil }

      it "returns an empty list" do
        expect(subject.validate).to be_empty
      end
    end

    context "when there are not available storage devices" do
      let(:available_devices) { [] }

      it "returns an error" do
        errors = subject.validate
        expect(errors.size).to eq(1)
        expect(errors.first.message).to include("not find a suitable device")
      end
    end

    context "when the proposal failed" do
      let(:failed) { true }

      it "returns an error" do
        errors = subject.validate
        expect(errors.size).to eq(1)
        expect(errors.first.message).to include("not create a storage proposal using /dev/sda")
      end
    end

    context "when no candidate devices are selected" do
      let(:candidate_devices) { [] }

      it "returns an error" do
        errors = subject.validate
        expect(errors.size).to eq(1)
        expect(errors.first.message).to include("No devices are selected for installation")
      end
    end
  end
end
