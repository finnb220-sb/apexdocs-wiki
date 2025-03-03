Profile baseProfile = [SELECT Id, Name FROM Profile WHERE Name = 'VAVET Base Profile' LIMIT 1];
Profile sysAdminProfile = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
List<User> usrs = [
    SELECT Id, name, Title, ProfileId, IsActive, Profile.Name, UserRole.Name
    FROM User
    WHERE (Title = 'VAHC DEV TEAM' OR Title = 'VAHC QA TEAM') AND ProfileId = :baseProfile.Id
];

for (User usr : usrs) {
    usr.ProfileId = sysAdminProfile.Id;
}

update usrs;
