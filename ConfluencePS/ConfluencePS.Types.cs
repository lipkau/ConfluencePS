using System;
using System.Collections.Generic;
using System.Collections;
// using System.Linq;

namespace AtlassianPS
{

    namespace ConfluencePS
    {

        public enum ContentStatus
        {
            // https://docs.atlassian.com/atlassian-confluence/6.6.0/com/atlassian/confluence/api/model/content/ContentStatus.html
            current,
            trashed,
            historical,
            draft,
            any
        }

        public enum SpaceType
        {
            // https://docs.atlassian.com/atlassian-confluence/6.6.0/com/atlassian/confluence/api/model/content/SpaceType.html
            global,
            personal
        }

        public enum CommentLocation
        {
            inline,
            footer,
            resolved
        }

        public enum CommentResolutionStatus
        {
            open,
            resolved
        }

        public class Icon
        {
            public String Path { get; set; }
            public UInt32 Width { get; set; }
            public UInt32 Height { get; set; }
            public Boolean IsDefault { get; set; }

            public override string ToString()
            {
                return Path;
            }
        }

        public class User
        {
            public User() { }

            public User(String UserName, String DisplayName)
            {
                this.UserName = UserName;
                this.DisplayName = DisplayName;
            }

            public String UserName { get; set; }
            public String DisplayName { get; set; }
            public String UserKey { get; set; }
            public Icon ProfilePicture { get; set; }
            public Uri Self { get; set; }

            public override string ToString()
            {
                return UserName;
            }
        }

        public class Version
        {
            public User By { get; set; }
            public DateTime When { get; set; }
            public String FriendlyWhen { get; set; }
            public UInt32 Number { get; set; }
            public String Message { get; set; }
            public Boolean MinorEdit { get; set; }
            public Uri Self { get; set; }

            public override string ToString()
            {
                return Number.ToString();
            }
        }

        public class Label
        {
            public Label(String _Name)
            {
                Prefix = "global";
                Name = _Name;
            }

            public UInt32 ID { get; set; }
            public String Prefix { get; set; }
            public String Name { get; set; }

            public override string ToString()
            {
                return Name;
            }
        }

        public class Space
        {
            public Space(String _Key)
            {
                Key = _Key;
            }

            public Space(String _Key, String _Name = "")
            {
                Key = _Key;
                Name = _Name;
            }

            public Space() {}

            public UInt32 Id { get; set; }
            public String Key { get; set; }
            public String Name { get; set; }
            public Icon Icon { get; set; }
            public SpaceType Type { get; set; }
            public String Description { get; set; }
            public Page Homepage { get; set; }
            public Uri Self { get; set; }

            public override string ToString()
            {
                return "[" + Key + "] " + Name;
            }
        }

        public class Page
        {
            // TODO
            // public Page() {}

            public UInt32 ID { get; set; }
            public ContentStatus Status { get; set; }
            public String Title { get; set; }
            public Space Space { get; set; }
            public User Author { get; set; }
            public Version Version { get; set; }
            public String Body { get; set; }
            public Page[] Ancestors { get; set; }
            public Label[] Labels { get; set; }
            public Uri URL { get; set; }
            public Uri ShortURL { get; set; }
            public Uri Self { get; set; }

            public override string ToString()
            {
                return "[" + ID + "] " + Title;
            }
        }

        public class Attachment
        {
            public UInt32 ID { get; set; }
            public ContentStatus Status { get; set; }
            public String Title { get; set; }
            public String Filename { get; set; }
            public String MediaType { get; set; }
            public UInt32 FileSize { get; set; }
            public String Comment { get; set; }
            public String SpaceKey { get; set; }
            public UInt32 PageID { get; set; }
            public Version Version { get; set; }
            public Label[] Labels { get; set; }
            public Uri URL { get; set; }
            public Uri Self { get; set; }

            public override string ToString()
            {
                return "[att" + ID + "] " + Title;
            }
        }

        public class BlogPost
        {
            // TODO
        }

        public class Comment
        {
            public UInt32 ID { get; set; }
            public ContentStatus Status { get; set; }
            public String Title { get; set; }
            public User Author { get; set; }
            public Version Version { get; set; }
            public String Body { get; set; }
            public CommentLocation Location { get; set; }
            public CommentResolution Resolution { get; set; }
            public CommentInlineProperties InlineProperties { get; set; }
            public Uri URL { get; set; }
            public Uri Self { get; set; }

            public override string ToString()
            {
                return "[com" + ID + "] " + Title;
            }
        }

        public class CommentResolution
        {
            public CommentResolutionStatus Status { get; set; }
            public User LastModifier { get; set; }
            public DateTime LastModifiedDate { get; set; }

            public override string ToString()
            {
                return Status.ToString();
            }
        }

        public class CommentInlineProperties
        {
            public String MarkerReference { get; set; }
            public String OriginalSelection { get; set; }
        }
    }
}
