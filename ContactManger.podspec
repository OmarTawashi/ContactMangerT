Pod::Spec.new do |s|

# 1
s.platform = :ios
s.ios.deployment_target = '9.0'
s.name = "ContactManger"
s.summary = "ContactManger lets a user browse contact framework."
s.requires_arc = true

# 2
s.version = "0.1.0"

# 3
s.license = { :type => "MIT", :file => "LICENSE" }

s.author = { "Omar Al tawashi" => "omaromar510@gmail.com" }



# 5 - Replace this URL with your own Github page's URL (from the address bar)
s.homepage = "https://github.com/OmarTawashi/ContactManger"


# 6 - Replace this URL with your own Git URL from "Quick Setup"
s.source = { :git => "https://github.com/OmarTawashi/ContactManger.git", :tag => "#{s.version}"}



# 7
s.framework = "UIKit"
s.framework = "CoreData"
s.framework = "AddressBook"
s.framework = "Contacts"
s.framework = "ContactsUI"
s.dependency 'NSManagedObject-HYPPropertyMapper'
s.dependency 'DATAFilter'

# 8
s.source_files = "ContactManger/**/*.{swift}"

# 9
s.resources = "ContactManger/**/*.{png,jpeg,jpg,storyboard,xib}"
end
