/**
 *
 * Class Description
 *
 * @author barne
 * @version 1.0.0
 */
@isTest
public without sharing class TestDataFactory {
    public static final String DATE_FORMAT = 'yyyy-MM-dd';

    public static final String DATE_START_WITHOUT_TIMESHEETS = '2020-01-06';
    public static final String DATE_END_WITHOUT_TIMESHEETS = '2020-01-12';

    public static final Integer USERS_COUNT = 10; //300
    public static final String USER_NAME_PATTERN = 'user%';
    public static final Map<String, Object> USER_PATTERN = new Map<String, Object>{
        'alias' => '',
        'email' => '',
        'emailEncodingKey' => 'UTF-8',
        'languageLocaleKey' => 'en_US',
        'localeSidKey' => 'en_US',
        'name' => 'user',
        'lastName' => 'lastname',
        'communityNickname' => '',
        'profileId' => '',
        'timeZoneSidKey' => 'America/Los_Angeles',
        'userName' => '',
        'domain' => 'domain.com' //local variable
    };
    public static List<Map<String, Object>> users = new List<Map<String, Object>>();

    public static final Integer ACCOUNTS_COUNT = 10; //300
    public static final String ACCOUNT_NAME_PATTERN = 'company%';
    public static final String ACCOUNT_STATUS_ACTIVE = 'Activated';
    public static final Map<String, Object> ACCOUNT_PATTERN = new Map<String, Object>{ 'name' => 'company' };
    public static List<Map<String, Object>> accounts = new List<Map<String, Object>>();

    public static final Integer CONTACTS_COUNT = 10; //300
    public static final String CONTACT_NAME_PATTERN = 'contact%';
    public static final Map<String, Object> CONTACT_PATTERN = new Map<String, Object>{
        'name' => 'contact',
        'firstName' => 'contact_f',
        'lastName' => 'contact_l',
        'email' => null,
        'accountid' => null,
        'domain' => 'domain.com'
    };
    public static List<Map<String, Object>> contacts = new List<Map<String, Object>>();

    public static final Integer PRODUCTS_COUNT = 10; //300
    public static final String PRODUCT_NAME_PATTERN = 'development%';
    public static final Map<String, Object> PRODUCT_PATTERN = new Map<String, Object>{ 'name' => 'Development', 'isActive' => true };
    public static List<Map<String, Object>> products = new List<Map<String, Object>>();

    public static final Integer PRICEBOOKS_COUNT = 10; //300
    public static final String PRICEBOOK_NAME_PATTERN = 'pricebook%';
    public static final Map<String, Object> PRICEBOOK_PATTERN = new Map<String, Object>{ 'name' => 'pricebook', 'isActive' => true, 'isStandart' => false };
    public static List<Map<String, Object>> pricebooks = new List<Map<String, Object>>();

    public static final Integer PRICEBOOK_ENTRIES_COUNT = 10; //300
    public static final Decimal PRICEBOOK_ENTRY_UNIT_PRICE = 50.00;
    public static final Map<String, Object> PRICEBOOK_ENTRY_PATTERN = new Map<String, Object>{
        'isActive' => true,
        'unitPrice' => PRICEBOOK_ENTRY_UNIT_PRICE,
        'pricebook2Id' => null,
        'product2Id' => null,
        'useStandardPrice' => false
    };
    public static List<Map<String, Object>> pricebookEntries = new List<Map<String, Object>>();

    public static final Integer CONTRACTS_COUNT = 10; //300
    public static final String CONTRACT_NAME_PATTERN = 'contract%';
    public static final String CONTRACT_STATUS_IN_Approval_Process = 'In Approval Process';
    public static final String CONTRACT_STATUS_DRAFT = 'Draft';
    public static final String CONTRACT_STATUS_ACTIVED = 'Activated';
    public static final Map<String, Object> CONTRACT_PATTERN = new Map<String, Object>{
        'accountId' => null,
        'status' => CONTRACT_STATUS_DRAFT,
        'startDate' => null,
        'contractTerm' => null,
        'pricebook2Id' => null,
        'name' => 'contract'
    };
    public static List<Map<String, Object>> contracts = new List<Map<String, Object>>{
        new Map<String, Object>{
            'count' => 3, //100
            'useParentId' => true,
            'useDiffParentId' => true,
            'contractTerm' => 8,
            'starDate' => Datetime.newInstance(2019, 6, 1)
        },
        new Map<String, Object>{
            'count' => 6, //150
            'useParentId' => true,
            'useDiffParentId' => true,
            'contractTerm' => 4,
            'startDate' => Datetime.newInstance(2019, 11, 1)
        },
        new Map<String, Object>{
            'count' => 1, //50
            'useParentId' => true,
            'useDiffParentId' => false,
            'contractTerm' => 1,
            'startDate' => Datetime.newInstance(2019, 12, 1)
        }
    };

    public static final Map<String, Object> TIMESHEET_ENTRY_PATTERN = new Map<String, Object>{
        'contractResource' => null, //String:Contract_Resource__c
        'product' => null, //String:Product__c
        'date' => null, //Date:Date__c
        'minutes' => null, //Decimal:Minutes__c
        'employee' => null, //String:Employee__c
        'approved' => null //Boolean:Is_Approved__c
    };
    public static List<Map<String, Object>> timesheetEntries = new List<Map<String, Object>>{};

    public static final String TIMESHEET_STATUS_NEW = 'New';
    public static final String TIMESHEET_STATUS_PENDING = 'Pending';
    public static final String TIMESHEET_STATUS_APPROVED = 'Approved';
    public static final String TIMESHEET_STATUS_PAID = 'Paid';

    public static final String TIME_REPORTS_STATUS_APPROVED = 'Approved';
    public static final String TIME_REPORTS_STATUS_NEW = 'New';
    public static final String TIME_REPORTS_STATUS_UNLOCKED = 'unlocked';

    public static final String EXPENSE_TYPE_AIRFARE = 'Airfare';
    public static final String EXPENSE_TYPE_HOTEL_ROOM = 'Hotel Room';
    public static final String EXPENSE_TYPE_MEAL = 'Meal';
    public static final String EXPENSE_TYPE_RENTAL_CAR = 'Rental Car';

    public static final Map<String, Object> configDateRanges = new Map<String, Object>{
        /*'2019-06-03_2019-06-09' => new Map<String, Object>{
              'startDate' => '2019-06-03',
              'endDate' => '2019-06-09',
              'status' => 'approved'
            },
            '2019-06-10_2019-06-16' => new Map<String, Object>{
              'startDate' => '2019-06-10',
              'endDate' => '2019-06-16',
              'status' => 'approved'
            },
            '2019-06-17_2019-06-23' => new Map<String, Object>{
              'startDate' => '019-06-17',
              'endDate' => '2019-06-23',
              'status' => 'approved'
            },
            '2019-06-24_2019-06-30' => new Map<String, Object>{
              'startDate' => '2019-06-24',
              'endDate' => '2019-06-30',
              'status' => 'approved'
            },
            '2019-07-01_2019-07-07' => new Map<String, Object>{
              'startDate' => '2019-07-01',
              'endDate' => '2019-07-07',
              'status' => 'new'
            },
            '2019-07-08_2019-07-14' => new Map<String, Object>{
              'startDate' => '2019-07-08',
              'endDate' => '2019-07-14',
              'status' => 'new'
            },
            '2019-07-15_2019-07-21' => new Map<String, Object>{
              'startDate' => '2019-07-15',
              'endDate' => '2019-07-21',
              'status' => 'new'
            },
            '2019-07-22_2019-07-28' => new Map<String, Object>{
              'startDate' => '2019-07-22',
              'endDate' => '2019-07-28',
              'status' => 'new'
            },
            '2019-07-29_2019-08-04' => new Map<String, Object>{
              'startDate' => '2019-07-29',
              'endDate' => '2019-08-04',
              'status' => 'new'
            },
            '2019-08-05_2019-08-11' => new Map<String, Object>{
              'startDate' => '2019-08-05',
              'endDate' => '2019-08-11',
              'status' => 'pending'
            },
            '2019-08-12_2019-08-18' => new Map<String, Object>{
              'startDate' => '2019-08-12',
              'endDate' => '2019-08-18',
              'status' => 'pending'
            },
            '2019-08-19_2019-08-25' => new Map<String, Object>{
              'startDate' => '2019-08-19',
              'endDate' => '2019-08-25',
              'status' => 'pending'
            },
            '2019-08-26_2019-09-01' => new Map<String, Object>{
              'startDate' => '2019-08-26',
              'endDate' => '2019-09-01',
              'status' => 'pending'
            },
            '2019-09-02_2019-09-08' => new Map<String, Object>{
              'startDate' => '2019-09-02',
              'endDate' => '2019-09-08',
              'status' => 'approved'
            },
            '2019-09-09_2019-09-15' => new Map<String, Object>{
              'startDate' => '2019-09-09',
              'endDate' => '2019-09-15',
              'status' => 'new'
            },
            '2019-09-16_2019-09-22' => new Map<String, Object>{
              'startDate' => '2019-09-16',
              'endDate' => '2019-09-22',
              'status' => 'pending'
            },
            '2019-09-23_2019-09-29' => new Map<String, Object>{
              'startDate' => '2019-09-23',
              'endDate' => '2019-09-29',
              'status' => 'approved'
            },
            '2019-09-30_2019-10-06' => new Map<String, Object>{
              'startDate' => '2019-09-30',
              'endDate' => '2019-10-06',
              'status' => 'approved'
            },
            '2019-10-07_2019-10-13' => new Map<String, Object>{
              'startDate' => '2019-10-07',
              'endDate' => '2019-10-13',
              'status' => 'new'
            },
            '2019-10-14_2019-10-20' => new Map<String, Object>{
              'startDate' => '2019-10-14',
              'endDate' => '2019-10-20',
              'status' => 'pending'
            },
            '2019-10-21_2019-10-27' => new Map<String, Object>{
              'startDate' => '2019-10-21',
              'endDate' => '2019-10-27',
              'status' => 'approved'
            },
            '2019-10-28_2019-11-03' => new Map<String, Object>{
              'startDate' => '2019-10-28',
              'endDate' => '28_2019-11-03',
              'status' => 'new'
            },
            '2019-11-04_2019-11-10' => new Map<String, Object>{
              'startDate' => '2019-11-04',
              'endDate' => '2019-11-10',
              'status' => 'pending'
            },
            '2019-11-11_2019-11-17' => new Map<String, Object>{
              'startDate' => '2019-11-11',
              'endDate' => '11_2019-11-17',
              'status' => 'pending'
            },
            '2019-11-18_2019-11-24' => new Map<String, Object>{
              'startDate' => '2019-11-18',
              'endDate' => '2019-11-24',
              'status' => 'pending'
            },
            '2019-11-25_2019-12-01' => new Map<String, Object>{
              'startDate' => '2019-11-25',
              'endDate' => '2019-12-01',
              'status' => 'pending'
            },*/
        '2019-12-02_2019-12-08' => new Map<String, Object>{ 'startDate' => '2019-12-02', 'endDate' => '2019-12-08', 'status' => 'approved', 'createTimesheet' => true },
        '2019-12-09_2019-12-15' => new Map<String, Object>{ 'startDate' => '2019-12-09', 'endDate' => '2019-12-15', 'status' => 'approved', 'createTimesheet' => true },
        '2019-12-16_2019-12-22' => new Map<String, Object>{ 'startDate' => '2019-12-16', 'endDate' => '2019-12-22', 'status' => 'approved', 'createTimesheet' => true },
        '2019-12-23_2019-12-29' => new Map<String, Object>{ 'startDate' => '2019-12-23', 'endDate' => '2019-12-29', 'status' => 'pending', 'createTimesheet' => true },
        '2019-12-30_2020-01-05' => new Map<String, Object>{ 'startDate' => '2019-12-30', 'endDate' => '2020-01-05', 'status' => 'new', 'createTimesheet' => true },
        DATE_START_WITHOUT_TIMESHEETS +
        '_' +
        DATE_END_WITHOUT_TIMESHEETS => new Map<String, Object>{
            'startDate' => DATE_START_WITHOUT_TIMESHEETS,
            'endDate' => DATE_END_WITHOUT_TIMESHEETS,
            'status' => 'new',
            'createTimesheet' => false
        }
    };

    public static final List<Map<String, String>> FILES = new List<Map<String, String>>{
        new Map<String, String>{
            'id' => null,
            'type' => 'text/plain',
            'name' => 'file-unit-test.txt',
            'content' => 'dGVzdCBjb250ZW50IGZvciB1bml0IHRlc3QuIGZpbGUgdXBsb2FkCg==',
            'recordId' => null
        }
    };

    public static void init() {
        insertUsers();
        insertAccounts();
        insertContacts();
    }

    public static void insertUsers() {
        List<User> users = new List<User>();

        Profile p = getProfileFromDb('Standard User');

        for (Integer i = 0; i < USERS_COUNT; i++) {
            String name = (String) USER_PATTERN.get('name') + '_' + i;
            String lastname = (String) USER_PATTERN.get('lastName') + '_' + i;
            String uid = (String) USER_PATTERN.get('name') + '_' + i;

            User u = new User(
                Alias = uid,
                Email = uid + '@' + (String) USER_PATTERN.get('domain'),
                EmailEncodingKey = (String) USER_PATTERN.get('emailEncodingKey'),
                //Name = name,
                LastName = lastname,
                LanguageLocaleKey = (String) USER_PATTERN.get('languageLocaleKey'),
                LocaleSidKey = (String) USER_PATTERN.get('localeSidKey'),
                ProfileId = p.Id,
                TimeZoneSidKey = (String) USER_PATTERN.get('timeZoneSidKey'),
                UserName = (uid +
                '@' +
                (String) USER_PATTERN.get('domain'))
            );
            users.add(u);
        }

        insert users;
    }

    public static List<User> getUsersFromDb() {
        Set<String> standardUsers = new Set<String>{ 'User', 'User User', 'Automated Process', 'Data.com Clean', 'Integration User', 'Security User', 'Chatter Expert' };

        return [SELECT Id, Alias, Email, Name FROM User WHERE Name NOT IN :standardUsers AND Email LIKE :USER_NAME_PATTERN];
    }

    public static List<User> getStandartUsersFromDb() {
        Set<String> standardUsers = new Set<String>{ 'Automated Process', 'Data.com Clean', 'Integration User', 'Security User', 'Chatter Expert' };

        return [SELECT Id FROM User WHERE Name NOT IN :standardUsers];
    }

    public static Profile getProfileFromDb(String name) {
        return [SELECT Id FROM Profile WHERE Name = :name LIMIT 1];
    }

    public static void insertAccounts() {
        List<Account> accounts = new List<Account>();

        String name = (String) ACCOUNT_PATTERN.get('name');

        for (Integer i = 0; i < ACCOUNTS_COUNT; i++) {
            Account account = new Account(Name = (name + '_' + i));
            accounts.add(account);
        }

        insert accounts;
    }

    public static List<Account> getAccountsFromDb() {
        return [SELECT Id, Name FROM Account];
    }

    public static void insertContacts() {
        List<Account> accounts = getAccountsFromDb();
        Integer totalNumberAccounts = accounts.size();
        List<Contact> contacts = new List<Contact>();

        String name = (String) CONTACT_PATTERN.get('name');
        String firstName = (String) CONTACT_PATTERN.get('firstName');
        String lastName = (String) CONTACT_PATTERN.get('lastName');
        String domain = (String) CONTACT_PATTERN.get('domain');

        for (Integer i = 0; i < CONTACTS_COUNT; i++) {
            Contact contact = new Contact();

            if (i > totalNumberAccounts) {
                contact.AccountId = accounts.get(totalNumberAccounts).Id;
            } else {
                contact.AccountId = accounts.get(i).Id;
            }

            contact.FirstName = (firstName + '_' + i);
            contact.LastName = (lastName + '_' + i);
            contact.Email = (name + '_' + i + '@' + domain);
            contacts.add(contact);
        }

        insert contacts;
    }

    public static List<Contact> getContactsFromDb() {
        return [SELECT Id, Name, AccountId FROM Contact WHERE Email LIKE :CONTACT_NAME_PATTERN];
    }

    public static Set<String> getAccountsNames() {
        Set<String> names = new Set<String>();

        String namePattern = (String) ACCOUNT_PATTERN.get('name');

        for (Integer i = 0; i < ACCOUNTS_COUNT; i++) {
            names.add(namePattern + '_' + i);
        }

        return names;
    }
    public static Contact getContactFromDb() {
        return [SELECT Id FROM Contact LIMIT 1];
    }

    public static String getUserId() {
        List<User> users = getUsersFromDb();
        return users.get(0).Id;
    }

    public static Set<String> getUsersIds() {
        Set<String> ids = new Set<String>();

        List<User> users = getUsersFromDb();

        for (User u : users) {
            ids.add((String) u.Id);
        }

        return ids;
    }

    public static String convertDateToString(Datetime d) {
        DateTime dt = DateTime.newInstanceGMT(d.year(), d.month(), d.day());
        return dt.formatGmt(TestDataFactory.DATE_FORMAT);
    }
}
