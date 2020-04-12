TestData = { name: ENV['DEFAULT_COMPANY'] || 'Auto Test Company',
    AcmeOrg: ENV['ORG_ID'] || 'id@Org',
    Library: "LibOne - #{ENV['UUID']}",
    LibraryToDelete: "To Delete Library",
    PropertyWeb: "#{ENV['USERNAME']} - Auto:Web Test - #{ENV['UUID']}",
    PropertyMobile: "#{ENV['USERNAME']} - Auto:Mobile Test - #{ENV['UUID']}",
    PermissionDevelop: "#{ENV['USERNAME']} #{ENV['PASS']}",
    PermissionAdmin: "#{ENV['USERNAME']} #{ENV['PASS']}",
    ReadOnlyPermission: "#{ENV['USERNAME']} #{ENV['PASS']}",
    SftpKey: ENV['SFTP_KEY'] || 'unset',
    SftpUsername:  "#{ENV['USERNAME']}",
    SftpPass:  "#{ENV['PASS']}",
    SftpHost: 'host.com',
    SftpPath: 'www'
}

DEBUG = false
BOUNDARY = "AaB03x"
