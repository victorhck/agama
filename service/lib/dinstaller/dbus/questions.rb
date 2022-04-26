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

require "dbus"
require "pathname"
require "dinstaller/dbus/question"

module DInstaller
  module DBus
    # This class represents a D-Bus object implementing ObjectManager interface for questions
    #
    # {DBus::Questions} uses a {QuestionsManager} as backend and exports a {DBus::Question} object
    # when a {DInstaller::Question} is added to the questions manager. A {DBus::Question} is
    # unexported when a {DInstaller::Question} is deleted from the questions manager.
    #
    # Callbacks of {QuestionsManager} are used to ensure that the proper D-Bus actions are performed
    # when adding, deleting or waiting for answers.
    class Questions < ::DBus::Object
      PATH = "/org/opensuse/DInstaller/Questions1"
      private_constant :PATH

      OBJECT_MANAGER_INTERFACE = "org.freedesktop.DBus.ObjectManager"
      private_constant :OBJECT_MANAGER_INTERFACE

      # Constructor
      #
      # The callbacks of the backend are configured to perform the proper D-Bus actions, see
      # {#register_callbacks}.
      #
      # @param backend [DInstaller::QuestionsManager]
      # @param logger [Logger]
      def initialize(backend, logger)
        @backend = backend
        @logger = logger
        @exported_questions = []

        register_callbacks

        super(PATH)
      end

      # Information provided by ObjectManger for each exported object
      #
      # Returns a hash containing paths of exported objects as keys. Each value is the information
      # of interfaces and properties for that object, see {#interfaces_and_properties}.
      #
      # @return [Hash]
      def managed_objects
        exported_questions.each_with_object({}) { |q, h| h[q.path] = interfaces_and_properties(q) }
      end

      dbus_interface OBJECT_MANAGER_INTERFACE do
        dbus_method(:GetManagedObjects, "out res:a{oa{sa{sv}}}") { [managed_objects] }
        dbus_signal(:InterfacesAdded, "object:o, interfaces_and_properties:a{sa{sv}}")
        dbus_signal(:InterfacesRemoved, "object:o, interfaces:as")
      end

    private

      # @return [DInstaller::QuestionsManager]
      attr_reader :backend

      # @return [Logger]
      attr_reader :logger

      # Currently exported questions
      #
      # @return [Array<DBus::Question>]
      attr_reader :exported_questions

      # Builds the question path (e.g., org.opensuse.DInstaller/Questions1/1)
      #
      # @param question [DInstaller::Question]
      # @return [::DBus::ObjectPath]
      def path_for(question)
        path = Pathname.new(PATH).join(question.id.to_s)

        ::DBus::ObjectPath.new(path.to_s)
      end

      # Generates information about interfaces and properties for the given question
      #
      # Returns a hash containing interfaces names as keys. Each value is the same hash that would
      # be returned by the org.freedesktop.DBus.Properties.GetAll() method for that combination of
      # object path and interface. If an interface has no properties, the empty hash is returned.
      #
      # @param question [DBus::Question]
      # @return [Hash]
      def interfaces_and_properties(question)
        get_all_method = self.class.make_method_name("org.freedesktop.DBus.Properties", :GetAll)

        question.intfs.keys.each_with_object({}) do |interface, hash|
          hash[interface] = question.public_send(get_all_method, interface).first
        end
      end

      # Callbacks with actions to do when adding, deleting or waiting for questions
      def register_callbacks
        # When adding a question, a new question is exported on D-Bus.
        backend.on_add do |question|
          dbus_object = DBus::Question.new(path_for(question), question, logger)
          @service.export(dbus_object)
          exported_questions << dbus_object
          InterfacesAdded(dbus_object.path, interfaces_and_properties(dbus_object))
        end

        # When removing a question, the question is unexported from D-Bus.
        backend.on_delete do |question|
          dbus_object = exported_questions.find { |q| q.id == question.id }
          if dbus_object
            @service.unexport(dbus_object)
            exported_questions.delete(dbus_object)
            InterfacesRemoved(dbus_object.path, dbus_object.intfs.keys)
          end
        end

        # Bus dispatches messages while waiting for questions to be answered
        backend.on_wait { @service.bus.dispatch_message_queue }
      end
    end
  end
end
