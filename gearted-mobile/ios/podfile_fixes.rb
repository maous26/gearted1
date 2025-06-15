# This file contains overrides for CocoaPods to fix gRPC compilation issues
# on iOS simulators with newer Xcode versions

# Override gRPC pods to remove problematic flags
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      
      # Fix for all gRPC related targets
      if target.name.include?('gRPC') || target.name.include?('BoringSSL') || target.name.include?('abseil')
        # Remove all -G flags from compiler flags
        %w[OTHER_CFLAGS OTHER_CPLUSPLUSFLAGS].each do |setting|
          current_flags = config.build_settings[setting] || ""
          if current_flags.is_a?(String)
            # Remove -G flags but keep -g (debug symbols)
            new_flags = current_flags.split.reject { |flag| flag.match?(/^-G[^g]/) || flag == "-G" }
            config.build_settings[setting] = new_flags.join(' ')
          end
        end
        
        # Additional settings to suppress warnings and errors
        config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = 'YES'
        config.build_settings['CLANG_WARN_EVERYTHING'] = 'NO'
        config.build_settings['WARNING_CFLAGS'] = '-w'
      end
      
      # General settings for better compatibility
      config.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
      config.build_settings['DEFINES_MODULE'] = 'YES'
      
      if config.name == 'Debug'
        config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'
      end
    end
  end
end
