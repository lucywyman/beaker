require 'spec_helper'

module Beaker
  describe FreeBSD::Pkg do
    class FreeBSDPkgTest
      include FreeBSD::Pkg

      def initialize(hash, logger)
        @hash = hash
        @logger = logger
      end

      def [](k)
        @hash[k]
      end

      def to_s
        "me"
      end

      def exec
        #noop
      end

    end

    let (:opts)     { @opts || {} }
    let (:logger)   { double( 'logger' ).as_null_object }
    let (:instance) { FreeBSDPkgTest.new(opts, logger) }
    let(:cond) do
      'TMPDIR=/dev/null ASSUME_ALWAYS_YES=1 PACKAGESITE=file:///nonexist pkg info -x "pkg(-devel)?\\$" > /dev/null 2>&1'
    end

    context "install_package" do
      let(:st) { 'pkg install -y rsync' }
      let(:sf) { 'pkg_add -r rsync' }

      it "runs the correct install command" do
        expect( Beaker::Command ).to receive(:new).with("/bin/sh -c 'if #{cond}; then #{st}; else #{sf}; fi'", [], {:prepend_cmds=>nil, :cmdexe=>false}).and_return('')
        expect( instance ).to receive(:exec).with('', {}).and_return(generate_result("hello", {:exit_code => 0}))
        instance.install_package('rsync')
      end

    end

    context "check_for_package" do
      let(:st) { 'pkg info rsync' }
      let(:sf) { 'pkg_info -Iqx rsync 2> /dev/null || true' }

      it "runs the correct checking command" do
        expect( Beaker::Command ).to receive(:new).with("/bin/sh -c 'if #{cond}; then #{st}; else #{sf}; fi'", [], {:prepend_cmds=>nil, :cmdexe=>false}).and_return('')
        expect( instance ).to receive(:exec).with('', {}).and_return(generate_result("hello", {:exit_code => 0}))
        instance.check_for_package('rsync')
      end

    end

  end
end

