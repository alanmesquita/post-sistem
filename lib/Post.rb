require "bundler/setup"
require "mysql"

class Post

    def initialize ()
        @@db = Mysql.new('localhost', 'root', '', 'r7')
    end

    def all(count='*', limit='')
        @@db.query "SELECT #{count} FROM posts WHERE parent_id IS NULL #{limit}"
    end

    def addPost(text)
        result = @@db.query('SELECT rgt FROM posts ORDER BY rgt DESC LIMIT 1')
        result = result.fetch_hash["rgt"]
        @@db.query "INSERT INTO posts(id, text, lft, rgt, date, parent_id)
                  VALUES(null, '#{text}', '#{result.to_i+1}', '#{result.to_i+2}', NOW(), null)"
    end

    def getChildrensByRootId(id)
        @@db.query 'SELECT node.id, node.text, (COUNT(parent.id) - (sub_tree.depth + 1)) AS depth
                  FROM posts AS node,
                    posts AS parent,
                    posts AS sub_parent,
                    (
                        SELECT node.id, (COUNT(parent.id) - 1) AS depth
                        FROM posts AS node,
                            posts AS parent
                        WHERE node.lft BETWEEN parent.lft AND parent.rgt
                            AND node.id = '+id+'
                        GROUP BY node.id
                        ORDER BY node.lft
                    ) AS sub_tree
                  WHERE node.lft BETWEEN parent.lft AND parent.rgt
                    AND node.lft BETWEEN sub_parent.lft AND sub_parent.rgt
                    AND sub_parent.id = sub_tree.id
                  GROUP BY node.id
                  ORDER BY node.lft'
    end

    def addReply(post)
        @@db.set_server_option Mysql::OPTION_MULTI_STATEMENTS_ON
        @@db.query 'SELECT @myLeft := lft FROM posts WHERE id = '+post["post_id"]+';
                    UPDATE posts SET rgt = rgt + 2 WHERE rgt > @myLeft;
                    UPDATE posts SET lft = lft + 2 WHERE lft > @myLeft;
                  INSERT INTO posts(id, text, lft, rgt, date, parent_id)
                  VALUES(null, "'+post["reply"]+'", @myLeft + 1, @myLeft + 2, NOW(), '+post["parent_id"]+')'
    end
end
